class ScheduleException < ApplicationRecord
  belongs_to :doctor, class_name: "User"

  validates :exception_date, presence: true, uniqueness: { scope: :doctor_id }

  scope :for_date, ->(date) { where(exception_date: date) }
  scope :unavailable, -> { where(available: false) }

  audited
end
