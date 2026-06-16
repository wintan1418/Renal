class ContactSubmission < ApplicationRecord
  belongs_to :responded_by, class_name: "User", optional: true
  belongs_to :assigned_to, class_name: "User", optional: true
  has_many :lead_activities, dependent: :destroy

  enum :status, { unread: 0, read: 1, responded: 2 }
  enum :stage, { new_lead: 0, contacted: 1, qualified: 2, booked: 3, converted: 4, lost: 5 }

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true

  scope :open_pipeline, -> { where.not(stage: [ :converted, :lost ]) }
  scope :due_followup, -> { where(stage: %i[new_lead contacted qualified booked]).where("follow_up_on <= ?", Date.current) }

  STAGE_META = {
    "new_lead"  => { label: "New",       color: "border-info" },
    "contacted" => { label: "Contacted", color: "border-primary" },
    "qualified" => { label: "Qualified", color: "border-secondary" },
    "booked"    => { label: "Booked",    color: "border-warning" },
    "converted" => { label: "Converted", color: "border-success" },
    "lost"      => { label: "Lost",      color: "border-error" }
  }.freeze

  def stage_label = STAGE_META.dig(stage, :label) || stage.to_s.humanize
end
