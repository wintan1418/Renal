class LabResult < ApplicationRecord
  audited

  belongs_to :lab_order
  belongs_to :lab_test
  belongs_to :patient, class_name: "User"
  belongs_to :resulted_by, class_name: "User", optional: true

  enum :flag, { normal: 0, low: 1, high: 2, critical: 3 }

  validates :lab_order_id, presence: true
  validates :lab_test_id, presence: true
  validates :patient_id, presence: true

  scope :recent, -> { order(result_date: :desc, created_at: :desc) }
  scope :for_patient, ->(patient_id) { where(patient_id: patient_id) }
  scope :for_test, ->(test_id) { where(lab_test_id: test_id) }
  scope :abnormal, -> { where(flag: [:low, :high, :critical]) }

  delegate :name, :unit, :normal_range, to: :lab_test, prefix: true

  def abnormal?
    low? || high? || critical?
  end
end
