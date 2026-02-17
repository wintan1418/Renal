class AppointmentReminderJob < ApplicationJob
  queue_as :default

  def perform(appointment_id)
    appointment = Appointment.find_by(id: appointment_id)
    return unless appointment&.status_confirmed?

    Notifications::DispatchService.call(
      recipient: appointment.patient,
      action: "appointment_reminder",
      title: "Appointment Reminder",
      body: "You have an appointment tomorrow with Dr. #{appointment.doctor&.full_name} at #{appointment.start_time&.strftime('%H:%M')}.",
      notifiable: appointment
    )
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "AppointmentReminderJob: Appointment #{appointment_id} not found"
  end
end
