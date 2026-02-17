module Appointments
  class CheckInService < ApplicationService
    ELIGIBLE_STATUSES = %w[pending confirmed].freeze

    def initialize(appointment:, checked_in_by:)
      @appointment = appointment
      @checked_in_by = checked_in_by
    end

    def call
      unless eligible_for_check_in?
        return Result.new(
          success?: false,
          data: nil,
          error: "Appointment cannot be checked in (current status: #{@appointment.status})"
        )
      end

      unless scheduled_for_today?
        return Result.new(
          success?: false,
          data: nil,
          error: "Appointment is not scheduled for today (scheduled: #{@appointment.scheduled_date})"
        )
      end

      assign_queue_number
      @appointment.status = :checked_in
      @appointment.checked_in_by = @checked_in_by
      @appointment.checked_in_at = Time.current

      if @appointment.save
        Result.new(success?: true, data: @appointment)
      else
        Result.new(success?: false, data: nil, error: @appointment.errors.full_messages.join(", "))
      end
    rescue => e
      Result.new(success?: false, data: nil, error: e.message)
    end

    private

    def eligible_for_check_in?
      ELIGIBLE_STATUSES.include?(@appointment.status)
    end

    def scheduled_for_today?
      @appointment.scheduled_date == Date.current
    end

    def assign_queue_number
      return if @appointment.queue_number.present?

      last_queue = Appointment
        .where(doctor_id: @appointment.doctor_id, scheduled_date: Date.current)
        .where.not(queue_number: nil)
        .maximum(:queue_number) || 0

      @appointment.queue_number = last_queue + 1
    end
  end
end
