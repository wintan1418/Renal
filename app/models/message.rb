class Message < ApplicationRecord
  belongs_to :conversation, touch: true
  belongs_to :sender, class_name: "User"

  validates :body, presence: true

  scope :chronological, -> { order(created_at: :asc) }

  def read?
    read_at.present?
  end

  def read_by!(user)
    update!(read_at: Time.current) if sender != user && read_at.nil?
  end
end
