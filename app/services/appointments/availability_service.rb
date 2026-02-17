module Appointments
  class AvailabilityService < ApplicationService
    # Takes a doctor (User) and a date, returns available time slots.
    #
    # Checks doctor_schedules for that day_of_week, applies schedule_exceptions
    # (blocked dates or modified hours), removes already-booked slots from
    # existing appointments, and returns an array of Time objects representing
    # available start times.

    ACTIVE_APPOINTMENT_STATUSES = %w[pending confirmed checked_in in_progress].freeze

    def initialize(doctor:, date:)
      @doctor = doctor
      @date = date.is_a?(String) ? Date.parse(date) : date
    end

    def call
      schedule = find_schedule
      return Result.new(success?: true, data: []) unless schedule

      exception = find_exception
      return Result.new(success?: true, data: []) if exception && !exception.available?

      slot_start, slot_end, duration = resolve_times(schedule, exception)
      return Result.new(success?: true, data: []) if slot_start.nil? || slot_end.nil?

      all_slots = generate_slots(slot_start, slot_end, duration)
      booked_slots = fetch_booked_slots(duration)
      available = remove_booked(all_slots, booked_slots, duration)

      Result.new(success?: true, data: available)
    rescue => e
      Result.new(success?: false, data: [], error: e.message)
    end

    private

    def find_schedule
      DoctorSchedule.find_by(
        doctor_id: @doctor.id,
        day_of_week: @date.wday,
        active: true
      )
    end

    def find_exception
      ScheduleException.find_by(
        doctor_id: @doctor.id,
        exception_date: @date
      )
    end

    def resolve_times(schedule, exception)
      if exception && exception.available?
        start_time = exception.start_time
        end_time = exception.end_time
      else
        start_time = schedule.start_time
        end_time = schedule.end_time
      end

      duration = schedule.slot_duration_minutes

      [start_time, end_time, duration]
    end

    def generate_slots(slot_start, slot_end, duration_minutes)
      slots = []
      current = time_on_date(slot_start)
      end_boundary = time_on_date(slot_end)

      while current + duration_minutes.minutes <= end_boundary
        slots << current
        current += duration_minutes.minutes
      end

      slots
    end

    def fetch_booked_slots(duration_minutes)
      Appointment
        .where(doctor_id: @doctor.id, scheduled_date: @date)
        .where(status: ACTIVE_APPOINTMENT_STATUSES)
        .pluck(:start_time, :end_time)
        .map do |start_time, end_time|
          booked_start = time_on_date(start_time)
          booked_end = end_time ? time_on_date(end_time) : booked_start + duration_minutes.minutes
          [booked_start, booked_end]
        end
    end

    def remove_booked(slots, booked_ranges, duration_minutes)
      slots.reject do |slot_start|
        slot_end = slot_start + duration_minutes.minutes
        booked_ranges.any? do |booked_start, booked_end|
          slot_start < booked_end && slot_end > booked_start
        end
      end
    end

    def time_on_date(time_value)
      Time.zone.local(@date.year, @date.month, @date.day, time_value.hour, time_value.min)
    end
  end
end
