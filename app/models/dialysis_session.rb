class DialysisSession < ApplicationRecord
  audited

  enum :session_type, { hemodialysis: 0, peritoneal: 1, hemofiltration: 2 }, prefix: true
  enum :status, { scheduled: 0, in_progress: 1, completed: 2, cancelled: 3, aborted: 4 }, prefix: true
  enum :access_type, { fistula: 0, graft: 1, catheter: 2 }, prefix: true

  belongs_to :appointment, optional: true
  belongs_to :patient, class_name: "User"
  belongs_to :doctor, class_name: "User"
  belongs_to :nurse, class_name: "User", optional: true
  belongs_to :dialysis_machine, optional: true
  belongs_to :dialysis_station, optional: true

  has_many :dialysis_consumable_usages, dependent: :destroy
  has_many :dialysis_consumables, through: :dialysis_consumable_usages
  has_many :vital_signs, dependent: :nullify

  validates :session_date, presence: true
  validates :patient, :doctor, :session_type, presence: true

  scope :today, -> { where(session_date: Date.current) }
  scope :upcoming, -> { where("session_date >= ?", Date.current).order(:session_date, :start_time) }
  scope :recent, -> { order(session_date: :desc, created_at: :desc) }
  scope :for_patient, ->(patient_id) { where(patient_id: patient_id) }
  scope :for_doctor, ->(doctor_id) { where(doctor_id: doctor_id) }

  def pre_blood_pressure
    return nil unless pre_systolic_bp && pre_diastolic_bp
    "#{pre_systolic_bp}/#{pre_diastolic_bp} mmHg"
  end

  def post_blood_pressure
    return nil unless post_systolic_bp && post_diastolic_bp
    "#{post_systolic_bp}/#{post_diastolic_bp} mmHg"
  end

  def fluid_removed_actual
    return nil unless pre_weight_kg && post_weight_kg
    ((pre_weight_kg - post_weight_kg) * 1000).round(0)
  end

  def ultrafiltration_achieved?
    return nil unless target_fluid_removal_ml && fluid_removed_ml
    fluid_removed_ml >= target_fluid_removal_ml * 0.9
  end

  def duration_hours
    return nil unless duration_minutes
    (duration_minutes / 60.0).round(1)
  end
end
