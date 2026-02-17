class RecurringSchedule < ApplicationRecord
  belongs_to :patient, class_name: "User"
  belongs_to :doctor, class_name: "User"
  belongs_to :service

  has_many :appointments, dependent: :nullify

  validates :days_of_week, :start_time, :start_date, presence: true
  validate :valid_days_of_week

  scope :active, -> { where(active: true) }

  audited

  private

  def valid_days_of_week
    return if days_of_week.blank?

    unless days_of_week.is_a?(Array) && days_of_week.all? { |d| (0..6).cover?(d) }
      errors.add(:days_of_week, "must only contain values between 0 and 6")
    end
  end
end
