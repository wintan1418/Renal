class Diagnosis < ApplicationRecord
  audited

  belongs_to :patient, class_name: "User"
  belongs_to :visit, optional: true
  belongs_to :diagnosed_by, class_name: "User", optional: true

  enum :diagnosis_type, { primary: 0, secondary: 1, differential: 2 }
  enum :status, { active: 0, resolved: 1, chronic: 2 }, prefix: true

  validates :description, presence: true
  validates :patient_id, presence: true

  scope :active_conditions, -> { where(status: [:active, :chronic]) }
  scope :for_patient, ->(patient_id) { where(patient_id: patient_id) }
  scope :recent, -> { order(created_at: :desc) }
end
