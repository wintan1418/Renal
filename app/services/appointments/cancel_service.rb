module Appointments
  class CancelService < ApplicationService
    NON_CANCELLABLE_STATUSES = %w[completed cancelled no_show].freeze

    def initialize(appointment:, cancellation_reason: nil)
      @appointment = appointment
      @cancellation_reason = cancellation_reason
    end

    def call
      unless cancellable?
        return Result.new(
          success?: false,
          data: nil,
          error: "Appointment cannot be cancelled (current status: #{@appointment.status})"
        )
      end

      @appointment.status = :cancelled
      @appointment.notes = append_cancellation_reason

      if @appointment.save
        Result.new(success?: true, data: @appointment)
      else
        Result.new(success?: false, data: nil, error: @appointment.errors.full_messages.join(", "))
      end
    rescue => e
      Result.new(success?: false, data: nil, error: e.message)
    end

    private

    def cancellable?
      !NON_CANCELLABLE_STATUSES.include?(@appointment.status)
    end

    def append_cancellation_reason
      existing = @appointment.notes.presence
      cancellation_note = @cancellation_reason.present? ? "Cancellation reason: #{@cancellation_reason}" : nil

      [existing, cancellation_note].compact.join("\n")
    end
  end
end
