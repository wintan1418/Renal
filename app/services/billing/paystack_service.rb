module Billing
  class PaystackService < ApplicationService
    BASE_URL = "https://api.paystack.co"

    def initialize(action:, **params)
      @action = action
      @params = params
    end

    def call
      case @action
      when :initialize_transaction
        initialize_transaction
      when :verify_transaction
        verify_transaction(@params[:reference])
      else
        Result.new(success?: false, error: "Unknown action: #{@action}")
      end
    end

    private

    def initialize_transaction
      response = client.post("/transaction/initialize") do |req|
        req.body = {
          email: @params[:email],
          amount: @params[:amount_cents],  # Paystack uses kobo (cents)
          reference: @params[:reference],
          callback_url: @params[:callback_url],
          metadata: @params[:metadata] || {}
        }.to_json
      end

      if response.success?
        data = JSON.parse(response.body)
        if data["status"]
          Result.new(success?: true, data: data["data"])
        else
          Result.new(success?: false, error: data["message"])
        end
      else
        Result.new(success?: false, error: "Paystack API error: #{response.status}")
      end
    rescue Faraday::Error => e
      Result.new(success?: false, error: "Network error: #{e.message}")
    end

    def verify_transaction(reference)
      response = client.get("/transaction/verify/#{reference}")

      if response.success?
        data = JSON.parse(response.body)
        if data["status"] && data["data"]["status"] == "success"
          Result.new(success?: true, data: data["data"])
        else
          Result.new(success?: false, error: "Payment not successful: #{data.dig('data', 'status')}")
        end
      else
        Result.new(success?: false, error: "Paystack API error: #{response.status}")
      end
    rescue Faraday::Error => e
      Result.new(success?: false, error: "Network error: #{e.message}")
    end

    def client
      @client ||= Faraday.new(BASE_URL) do |f|
        f.headers["Authorization"] = "Bearer #{Rails.application.credentials.dig(:paystack, :secret_key)}"
        f.headers["Content-Type"] = "application/json"
        f.headers["Accept"] = "application/json"
        f.adapter Faraday.default_adapter
      end
    end
  end
end
