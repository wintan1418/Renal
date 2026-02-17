class TransplantWaitlistEntry < ApplicationRecord
  audited
  enum :status, { active: 0, on_hold: 1, transplanted: 2, removed: 3 }, prefix: true
  enum :priority, { standard: 0, urgent: 1, super_urgent: 2 }, prefix: true

  belongs_to :patient, class_name: "User"

  validates :patient, :listed_date, :blood_group, presence: true
  validates :pra_level, numericality: { in: 0..100 }, allow_nil: true

  scope :active, -> { where(status: :active) }
  scope :by_priority, -> { order(priority: :desc, listed_date: :asc) }

  BLOOD_GROUPS = %w[A+ A- B+ B- AB+ AB- O+ O-].freeze

  def days_waiting
    (Date.current - listed_date).to_i
  end
end
