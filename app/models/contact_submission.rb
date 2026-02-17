class ContactSubmission < ApplicationRecord
  belongs_to :responded_by, class_name: "User", optional: true

  enum :status, { unread: 0, read: 1, responded: 2 }

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true
end
