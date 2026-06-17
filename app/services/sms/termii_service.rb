module Sms
  class TermiiService < ApplicationService
    BASE_URL = "https://api.ng.termii.com/api"

    def self.api_key
      ENV["TERMII_API_KEY"].presence || Rails.application.credentials.dig(:termii, :api_key)
    end

    def self.sender_id
      ENV["TERMII_SENDER_ID"].presence || Rails.application.credentials.dig(:termii, :sender_id) || "HealthRoom"
    end

    # True once an API key is available — lets callers no-op cleanly otherwise.
    def self.configured?
      api_key.present?
    end

    def initialize(to:, message:)
      @to = to
      @message = message
    end

    def call
      unless self.class.configured?
        Rails.logger.info("[Sms::Termii] skipped — no TERMII_API_KEY configured")
        return Result.new(success?: false, error: "SMS not configured")
      end

      response = client.post("/sms/send") do |req|
        req.body = {
          to: @to,
          from: self.class.sender_id,
          sms: @message,
          type: "plain",
          api_key: self.class.api_key,
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
