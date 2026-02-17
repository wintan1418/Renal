class DietLog < ApplicationRecord
  enum :meal_type, { breakfast: 0, lunch: 1, dinner: 2, snack: 3, total: 4 }, prefix: true

  belongs_to :patient, class_name: "User"

  validates :patient, :log_date, :meal_type, presence: true
  validates :fluid_intake_ml, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :for_date, ->(date) { where(log_date: date) }
  scope :recent, -> { order(log_date: :desc) }

  def self.daily_fluid_total(patient, date)
    where(patient: patient, log_date: date).sum(:fluid_intake_ml)
  end
end
