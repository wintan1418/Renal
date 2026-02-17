class PrescriptionItem < ApplicationRecord
  belongs_to :prescription

  validates :medication_name, presence: true
  validates :dosage, presence: true
  validates :frequency, presence: true

  def display
    "#{medication_name} #{dosage} - #{frequency}#{duration.present? ? " for #{duration}" : ""}"
  end
end
