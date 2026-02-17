class Allergy < ApplicationRecord
  audited

  belongs_to :patient, class_name: "User"

  enum :severity, { mild: 0, moderate: 1, severe: 2, life_threatening: 3 }

  validates :allergen, presence: true
  validates :patient_id, presence: true

  scope :active_allergies, -> { where(active: true) }
  scope :for_patient, ->(patient_id) { where(patient_id: patient_id) }
end
