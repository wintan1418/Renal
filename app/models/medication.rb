class Medication < ApplicationRecord
  audited

  belongs_to :patient, class_name: "User"
  belongs_to :prescribed_by, class_name: "User", optional: true

  validates :name, presence: true
  validates :patient_id, presence: true

  scope :active_medications, -> { where(active: true) }
  scope :for_patient, ->(patient_id) { where(patient_id: patient_id) }
  scope :recent, -> { order(created_at: :desc) }

  def display_name
    parts = [name]
    parts << dosage if dosage.present?
    parts << "(#{frequency})" if frequency.present?
    parts.join(" ")
  end
end
