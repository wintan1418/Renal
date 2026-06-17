class VascularAccess < ApplicationRecord
  belongs_to :patient, class_name: "User"

  enum :access_type, { fistula: 0, graft: 1, catheter: 2 }, prefix: :type
  enum :status, { functioning: 0, monitoring: 1, failing: 2, infected: 3, abandoned: 4 }, prefix: true

  validates :access_type, :status, presence: true

  scope :active, -> { where.not(status: [ :abandoned ]) }
  scope :recent, -> { order(created_on: :desc, created_at: :desc) }

  STATUS_BADGE = {
    "functioning" => "badge-success", "monitoring" => "badge-info",
    "failing" => "badge-warning", "infected" => "badge-error", "abandoned" => "badge-ghost"
  }.freeze

  def status_badge = STATUS_BADGE[status] || "badge-ghost"
  def label = "#{access_type.to_s.humanize}#{" · #{location}" if location.present?}"
end
