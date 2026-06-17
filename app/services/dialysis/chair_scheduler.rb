module Dialysis
  # Weekly chair/shift utilisation for the dialysis unit: booked vs capacity per
  # day and shift, with free slots — helps optimise chair rotation.
  class ChairScheduler < ApplicationService
    SHIFTS = [
      { key: :morning,   label: "Morning",   from: 6,  to: 11 },
      { key: :afternoon, label: "Afternoon", from: 11, to: 16 },
      { key: :evening,   label: "Evening",   from: 16, to: 22 }
    ].freeze

    def initialize(week_start: nil)
      @week_start = (week_start || Date.current.beginning_of_week)
    end

    def call
      days = (0..6).map { |i| @week_start + i }
      capacity = DialysisStation.count # chairs available each shift
      sessions = DialysisSession
                   .where(session_date: days.first..days.last, status: %i[scheduled in_progress completed])
                   .includes(:patient).to_a

      grid = days.map do |day|
        day_sessions = sessions.select { |s| s.session_date == day }
        shifts = SHIFTS.map do |sh|
          booked = day_sessions.count { |s| in_shift?(s, sh) }
          {
            label: sh[:label], booked: booked, capacity: capacity,
            free: [ capacity - booked, 0 ].max,
            pct: capacity.zero? ? 0 : ((booked.to_f / capacity) * 100).round,
            over: booked > capacity
          }
        end
        { date: day, total: day_sessions.size, shifts: shifts }
      end

      total = sessions.size
      weekly_capacity = capacity * SHIFTS.size * 7
      {
        week_start: @week_start, days: grid, chairs: capacity,
        total_booked: total, weekly_capacity: weekly_capacity,
        utilisation: weekly_capacity.zero? ? 0 : ((total.to_f / weekly_capacity) * 100).round
      }
    end

    private

    def in_shift?(session, shift)
      hour = session.start_time&.hour
      hour && hour >= shift[:from] && hour < shift[:to]
    end
  end
end
