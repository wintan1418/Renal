class RecurringAppointmentGeneratorJob < ApplicationJob
  queue_as :default

  # Run nightly to generate appointments from recurring schedules
  # Can be configured in config/recurring.yml for Solid Queue
  def perform(weeks_ahead: 4)
    Rails.logger.info "[RecurringAppointmentGenerator] Starting generation for #{weeks_ahead} weeks ahead"

    results = Appointments::RecurringGeneratorService.call(weeks_ahead: weeks_ahead)

    if results.success?
      Rails.logger.info "[RecurringAppointmentGenerator] Generated #{results.data[:created_count]} appointments"
    else
      Rails.logger.error "[RecurringAppointmentGenerator] Failed: #{results.error}"
    end
  end
end
