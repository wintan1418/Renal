class Webhooks::PaystackController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_paystack_signature

  def create
    event = params[:event]
    data = params[:data]

    case event
    when "charge.success"
      reference = data[:reference]
      PaystackWebhookProcessorJob.perform_later(reference)
    end

    head :ok
  end

  private

  def verify_paystack_signature
    secret = Rails.application.credentials.dig(:paystack, :secret_key)
    signature = request.headers["X-Paystack-Signature"]
    computed = OpenSSL::HMAC.hexdigest("SHA512", secret, request.raw_post)

    unless ActiveSupport::SecurityUtils.secure_compare(signature.to_s, computed)
      head :unauthorized
    end
  rescue
    head :unauthorized
  end
end
