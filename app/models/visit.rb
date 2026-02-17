class Visit < ApplicationRecord
  audited

  belongs_to :appointment, optional: true
  belongs_to :patient, class_name: "User"
  belongs_to :doctor, class_name: "User"

  has_many :clinical_notes, dependent: :destroy
  has_many :vital_signs, dependent: :destroy
  has_many :diagnoses, dependent: :nullify
  has_many :lab_orders, dependent: :destroy
  has_many :prescriptions, dependent: :destroy

  enum :visit_type, { outpatient: 0, inpatient: 1, emergency: 2, dialysis: 3, follow_up: 4 }
  enum :status, { in_progress: 0, completed: 1, cancelled: 2 }, prefix: true

  validates :visit_date, presence: true
  validates :patient_id, presence: true
  validates :doctor_id, presence: true

  scope :recent, -> { order(visit_date: :desc) }
  scope :for_patient, ->(patient_id) { where(patient_id: patient_id) }
  scope :for_doctor, ->(doctor_id) { where(doctor_id: doctor_id) }
  scope :on_date, ->(date) { where(visit_date: date) }
  scope :today, -> { where(visit_date: Date.current) }
end
