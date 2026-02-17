class NotificationPreference < ApplicationRecord
  belongs_to :user

  validates :notification_type, presence: true
  validates :user_id, uniqueness: { scope: :notification_type }

  TYPES = %w[appointment_reminder lab_result_ready invoice_generated payment_received
             low_stock_alert new_message].freeze
end
