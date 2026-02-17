class ClinicalNote < ApplicationRecord
  audited

  belongs_to :visit
  belongs_to :author, class_name: "User"

  enum :note_type, { soap: 0, progress: 1, procedure: 2, discharge: 3, nursing: 4 }

  validates :visit_id, presence: true
  validates :author_id, presence: true

  # For SOAP notes, at least one section should be filled
  validate :soap_has_content, if: :soap?

  delegate :patient, to: :visit

  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(note_type: type) }

  private

  def soap_has_content
    if subjective.blank? && objective.blank? && assessment.blank? && plan.blank?
      errors.add(:base, "SOAP note must have content in at least one section")
    end
  end
end
