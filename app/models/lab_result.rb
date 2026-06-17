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

  # Escalate a critical result to the ordering clinician as soon as it's set.
  after_save :escalate_if_critical, if: -> { saved_change_to_flag? && critical? }

  def abnormal?
    low? || high? || critical?
  end

  private

  def escalate_if_critical
    doctor = lab_order&.ordered_by
    return if doctor.nil?

    Notifications::DispatchService.call(
      recipient: doctor,
      actor: resulted_by,
      notifiable: self,
      action: "critical_result",
      title: "⚠ Critical lab result: #{lab_test&.name}",
      body: "#{patient&.full_name}: #{lab_test&.name} = #{value} #{lab_test&.unit} (critical). Review urgently."
    )
  rescue StandardError => e
    Rails.logger.error("[LabResult escalate] #{e.class}: #{e.message}")
  end
end
