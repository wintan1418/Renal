class VitalSign < ApplicationRecord
  audited

  belongs_to :visit, optional: true
  belongs_to :patient, class_name: "User"
  belongs_to :recorded_by, class_name: "User"

  enum :measurement_type, { routine: 0, pre_dialysis: 1, post_dialysis: 2, emergency: 3 }

  validates :patient_id, presence: true
  validates :recorded_by_id, presence: true
  validates :recorded_at, presence: true
  validates :systolic_bp, numericality: { greater_than: 0, less_than: 300, allow_nil: true }
  validates :diastolic_bp, numericality: { greater_than: 0, less_than: 200, allow_nil: true }
  validates :heart_rate, numericality: { greater_than: 0, less_than: 300, allow_nil: true }
  validates :temperature, numericality: { greater_than: 30, less_than: 45, allow_nil: true }
  validates :weight_kg, numericality: { greater_than: 0, less_than: 500, allow_nil: true }
  validates :oxygen_saturation, numericality: { greater_than: 0, less_than_or_equal_to: 100, allow_nil: true }

  scope :recent, -> { order(recorded_at: :desc) }
  scope :for_patient, ->(patient_id) { where(patient_id: patient_id) }

  def blood_pressure
    return nil unless systolic_bp && diastolic_bp
    "#{systolic_bp}/#{diastolic_bp}"
  end

  def bmi
    return nil unless weight_kg && height_cm && height_cm > 0
    (weight_kg / ((height_cm / 100.0) ** 2)).round(1)
  end
end
