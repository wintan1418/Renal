class PaystackWebhookProcessorJob < ApplicationJob
  queue_as :default

  def perform(reference)
    payment = Payment.find_by(paystack_reference: reference)
    return unless payment&.status_pending?

    result = Billing::PaystackService.call(action: :verify_transaction, reference: reference)
    if result.success?
      payment.update!(status: :successful)
    else
      payment.update!(status: :failed)
    end
  end
end
