class LabOrder < ApplicationRecord
  audited

  belongs_to :visit, optional: true
  belongs_to :patient, class_name: "User"
  belongs_to :ordered_by, class_name: "User"

  has_many :lab_results, dependent: :destroy

  enum :status, { pending: 0, collected: 1, processing: 2, completed: 3, cancelled: 4 }, prefix: true
  enum :priority, { routine: 0, urgent: 1, stat: 2 }

  validates :patient_id, presence: true
  validates :ordered_by_id, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_patient, ->(patient_id) { where(patient_id: patient_id) }
  scope :pending_orders, -> { where(status: [:pending, :collected, :processing]) }

  def all_results_entered?
    lab_results.any? && lab_results.all? { |r| r.value.present? }
  end
end
