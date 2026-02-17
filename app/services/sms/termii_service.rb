module Sms
  class TermiiService < ApplicationService
    BASE_URL = "https://api.ng.termii.com/api"

    def initialize(to:, message:)
      @to = to
      @message = message
    end

    def call
      response = client.post("/sms/send") do |req|
        req.body = {
          to: @to,
          from: Rails.application.credentials.dig(:termii, :sender_id) || "HealthRoom",
          sms: @message,
          type: "plain",
          api_key: Rails.application.credentials.dig(:termii, :api_key),
          channel: "generic"
        }.to_json
      end

      if response.success?
        Result.new(success?: true, data: JSON.parse(response.body))
      else
        Result.new(success?: false, error: "Termii error: #{response.status}")
      end
    rescue Faraday::Error => e
      Result.new(success?: false, error: "Network error: #{e.message}")
    end

    private

    def client
      @client ||= Faraday.new(BASE_URL) do |f|
        f.headers["Content-Type"] = "application/json"
        f.adapter Faraday.default_adapter
      end
    end
  end
end
