class EmergencyContact < ApplicationRecord
  belongs_to :patient, class_name: "User"

  validates :name, :phone, :relationship, presence: true

  before_save :ensure_single_primary

  scope :primary_first, -> { order(is_primary: :desc) }

  private

  def ensure_single_primary
    if is_primary?
      patient.emergency_contacts.where.not(id: id).update_all(is_primary: false)
    end
  end
end
