class SmsDeliveryJob < ApplicationJob
  queue_as :default

  def perform(to:, message:)
    Sms::TermiiService.call(to: to, message: message)
  end
end
