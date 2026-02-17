class Prescription < ApplicationRecord
  audited

  belongs_to :visit, optional: true
  belongs_to :patient, class_name: "User"
  belongs_to :prescribed_by, class_name: "User"

  has_many :prescription_items, dependent: :destroy
  accepts_nested_attributes_for :prescription_items, reject_if: :all_blank, allow_destroy: true

  enum :status, { active: 0, dispensed: 1, partially_dispensed: 2, cancelled: 3 }, prefix: true

  validates :patient_id, presence: true
  validates :prescribed_by_id, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_patient, ->(patient_id) { where(patient_id: patient_id) }
  scope :active_prescriptions, -> { where(status: :active) }

  def item_count
    prescription_items.count
  end
end
