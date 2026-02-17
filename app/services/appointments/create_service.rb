module Appointments
  class CreateService < ApplicationService
    def initialize(patient:, doctor:, service:, scheduled_date:, start_time:, appointment_type: :walk_in, reason: nil)
      @patient = patient
      @doctor = doctor
      @service = service
      @scheduled_date = scheduled_date.is_a?(String) ? Date.parse(scheduled_date) : scheduled_date
      @start_time = start_time
      @appointment_type = appointment_type
      @reason = reason
    end

    def call
      unless slot_available?
        return Result.new(success?: false, data: nil, error: "Selected time slot is not available")
      end

      appointment = build_appointment
      if appointment.save
        Result.new(success?: true, data: appointment)
      else
        Result.new(success?: false, data: nil, error: appointment.errors.full_messages.join(", "))
      end
    rescue => e
      Result.new(success?: false, data: nil, error: e.message)
    end

    private

    def slot_available?
      availability = AvailabilityService.call(doctor: @doctor, date: @scheduled_date)
      return false unless availability.success?

      parsed_start = parse_start_time
      availability.data.any? { |slot| slot == parsed_start }
    end

    def build_appointment
      end_time = calculate_end_time

      Appointment.new(
        patient: @patient,
        doctor: @doctor,
        service: @service,
        department: @service.department,
        scheduled_date: @scheduled_date,
        start_time: @start_time,
        end_time: end_time,
        appointment_type: @appointment_type,
        reason: @reason,
        status: :pending
      )
    end

    def calculate_end_time
      duration = @service.duration_minutes || 30
      parsed = parse_start_time
      (parsed + duration.minutes).strftime("%H:%M")
    end

    def parse_start_time
      case @start_time
      when Time, ActiveSupport::TimeWithZone
        @start_time
      when String
        parts = @start_time.split(":").map(&:to_i)
        Time.zone.local(@scheduled_date.year, @scheduled_date.month, @scheduled_date.day, parts[0], parts[1])
      else
        time_on_date(@start_time)
      end
    end

    def time_on_date(time_value)
      Time.zone.local(@scheduled_date.year, @scheduled_date.month, @scheduled_date.day, time_value.hour, time_value.min)
    end
  end
end
