module Appointments
  class RecurringGeneratorService < ApplicationService
    def initialize(weeks_ahead: 4)
      @weeks_ahead = weeks_ahead
    end

    def call
      created_appointments = []
      errors = []

      active_schedules.find_each do |schedule|
        results = generate_for_schedule(schedule)
        created_appointments.concat(results[:created])
        errors.concat(results[:errors])
      end

      Result.new(
        success?: errors.empty?,
        data: { created: created_appointments, count: created_appointments.size, errors: errors }
      )
    rescue => e
      Result.new(success?: false, data: { created: [], count: 0, errors: [e.message] }, error: e.message)
    end

    private

    def active_schedules
      RecurringSchedule.where(active: true)
        .where("start_date <= ?", end_date)
        .where("end_date IS NULL OR end_date >= ?", Date.current)
    end

    def end_date
      @end_date ||= Date.current + @weeks_ahead.weeks
    end

    def generate_for_schedule(schedule)
      created = []
      errors = []

      candidate_dates(schedule).each do |date|
        next if appointment_exists?(schedule, date)
        next if doctor_unavailable?(schedule.doctor_id, date)

        appointment = build_appointment(schedule, date)

        if appointment.save
          created << appointment
        else
          errors << "Failed to create appointment for schedule ##{schedule.id} on #{date}: #{appointment.errors.full_messages.join(', ')}"
        end
      end

      { created: created, errors: errors }
    end

    def candidate_dates(schedule)
      start = [schedule.start_date, Date.current].max
      finish = schedule.end_date ? [schedule.end_date, end_date].min : end_date

      dates = []
      (start..finish).each do |date|
        dates << date if schedule.days_of_week.include?(date.wday)
      end
      dates
    end

    def appointment_exists?(schedule, date)
      Appointment.exists?(
        recurring_schedule_id: schedule.id,
        scheduled_date: date
      )
    end

    def doctor_unavailable?(doctor_id, date)
      ScheduleException.exists?(
        doctor_id: doctor_id,
        exception_date: date,
        available: false
      )
    end

    def build_appointment(schedule, date)
      end_time = calculate_end_time(schedule)

      Appointment.new(
        patient_id: schedule.patient_id,
        doctor_id: schedule.doctor_id,
        service_id: schedule.service_id,
        department_id: schedule.service.department_id,
        recurring_schedule_id: schedule.id,
        scheduled_date: date,
        start_time: schedule.start_time,
        end_time: end_time,
        appointment_type: :recurring,
        status: :pending,
        reason: "Auto-generated from recurring schedule ##{schedule.id}"
      )
    end

    def calculate_end_time(schedule)
      duration = schedule.service.duration_minutes || 30
      (Time.parse(schedule.start_time.strftime("%H:%M")) + duration.minutes).strftime("%H:%M")
    end
  end
end
