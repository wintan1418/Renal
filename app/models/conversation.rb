class Conversation < ApplicationRecord
  enum :status, { open: 0, closed: 1 }, prefix: true

  belongs_to :patient, class_name: "User"

  has_many :conversation_participants, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user
  has_many :messages, dependent: :destroy

  validates :subject, presence: true

  scope :open, -> { where(status: :open) }
  scope :recent, -> { order(updated_at: :desc) }

  def latest_message
    messages.order(created_at: :desc).first
  end

  def unread_count_for(user)
    messages.where.not(sender: user).where(read_at: nil).count
  end
end
