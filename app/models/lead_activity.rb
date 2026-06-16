class LeadActivity < ApplicationRecord
  belongs_to :contact_submission
  belongs_to :user, optional: true

  enum :kind, { note: 0, call: 1, email: 2, whatsapp: 3, stage_change: 4, meeting: 5 }

  validates :body, presence: true

  scope :recent, -> { order(created_at: :desc) }

  ICONS = {
    "note" => "📝", "call" => "📞", "email" => "✉️",
    "whatsapp" => "💬", "stage_change" => "🔁", "meeting" => "📅"
  }.freeze

  def icon = ICONS[kind] || "•"
end
