class AppointmentReminderJob < ApplicationJob
  queue_as :default

  def perform(appointment_id)
    appointment = Appointment.find_by(id: appointment_id)
    return unless appointment&.status_confirmed?

    message = "You have an appointment tomorrow with Dr. #{appointment.doctor&.full_name} at #{appointment.start_time&.strftime('%H:%M')}."

    Notifications::DispatchService.call(
      recipient: appointment.patient,
      action: "appointment_reminder",
      title: "Appointment Reminder",
      body: message,
      notifiable: appointment
    )

    # Also send by SMS when a number + provider key are available (no-ops otherwise).
    phone = appointment.patient&.phone
    if phone.present? && Sms::TermiiService.configured?
      SmsDeliveryJob.perform_later(to: phone, message: "Healthroom: #{message}")
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "AppointmentReminderJob: Appointment #{appointment_id} not found"
  end
end
