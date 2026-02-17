module Appointments
  class QueueService < ApplicationService
    QUEUED_STATUSES = %w[checked_in in_progress].freeze

    def initialize(doctor:, date: Date.current)
      @doctor = doctor
      @date = date.is_a?(String) ? Date.parse(date) : date
    end

    def call
      appointments = fetch_queue
      Result.new(success?: true, data: appointments)
    rescue => e
      Result.new(success?: false, data: [], error: e.message)
    end

    # Returns all appointments for this doctor/date ordered by queue_number
    def queue
      fetch_queue
    end

    # Returns the appointment currently being seen (in_progress)
    def current_patient
      fetch_queue.find { |appt| appt.status == "in_progress" }
    end

    # Returns the next patient in line (first checked_in appointment by queue order)
    def next_patient
      fetch_queue.select { |appt| appt.status == "checked_in" }.first
    end

    # Returns the queue position for a specific appointment
    def current_position(appointment)
      queued = fetch_queue.select { |appt| appt.status == "checked_in" }
      index = queued.index(appointment)
      index ? index + 1 : nil
    end

    # Returns total number of patients still waiting
    def waiting_count
      fetch_queue.count { |appt| appt.status == "checked_in" }
    end

    private

    def fetch_queue
      @fetch_queue ||= Appointment
        .where(doctor_id: @doctor.id, scheduled_date: @date)
        .where.not(queue_number: nil)
        .order(:queue_number)
        .to_a
    end
  end
end
