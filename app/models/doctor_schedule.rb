class DoctorSchedule < ApplicationRecord
  belongs_to :doctor, class_name: "User"

  DAY_NAMES = {
    0 => "Sunday",
    1 => "Monday",
    2 => "Tuesday",
    3 => "Wednesday",
    4 => "Thursday",
    5 => "Friday",
    6 => "Saturday"
  }.freeze

  validates :day_of_week, presence: true,
                          inclusion: { in: 0..6 },
                          uniqueness: { scope: :doctor_id }
  validates :start_time, :end_time, presence: true
  validates :slot_duration_minutes, numericality: { greater_than: 0 }
  validates :max_patients, numericality: { greater_than: 0 }
  validate :end_time_after_start_time

  scope :active, -> { where(active: true) }
  scope :for_day, ->(day) { where(day_of_week: day) }

  audited

  def day_name
    DAY_NAMES[day_of_week]
  end

  def available_slots(date)
    slots = []
    current_time = start_time

    while current_time + slot_duration_minutes.minutes <= end_time
      slot_end = current_time + slot_duration_minutes.minutes
      slots << { start_time: current_time, end_time: slot_end }
      current_time = slot_end
    end

    booked_times = Appointment
      .where(doctor_id: doctor_id, scheduled_date: date)
      .where.not(status: :cancelled)
      .pluck(:start_time)

    slots.reject { |slot| booked_times.include?(slot[:start_time]) }
  end

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end
