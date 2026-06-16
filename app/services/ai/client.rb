module Ai
  # The single point of contact with the LLM provider (RubyLLM → Gemini /
  # OpenAI). Everything else in app/services/ai goes through here. Never
  # raises — returns a Response so callers can fall back gracefully.
  class Client
    Response = Struct.new(:content, :model, :ok, :error, keyword_init: true) do
      def ok? = ok
    end

    class << self
      # Is at least one provider key configured?
      def available?
        cfg = RubyLLM.config
        cfg.gemini_api_key.present? || cfg.openai_api_key.present?
      rescue StandardError
        false
      end

      def chat(system:, prompt:, model: nil, temperature: 0.3)
        new.chat(system: system, prompt: prompt, model: model, temperature: temperature)
      end
    end

    def chat(system:, prompt:, model: nil, temperature: 0.3)
      model ||= resolve_model
      conversation = RubyLLM.chat(model: model)
      conversation.with_temperature(temperature) if conversation.respond_to?(:with_temperature)
      conversation.with_instructions(system) if system.present?

      result = conversation.ask(prompt)
      Response.new(content: result.content.to_s.strip, model: model, ok: true)
    rescue StandardError => e
      Rails.logger.error("[Ai::Client] #{e.class}: #{e.message}")
      Response.new(content: nil, model: model, ok: false, error: e.message)
    end

    private

    # Prefer Gemini when available, else OpenAI, else the configured default.
    def resolve_model
      cfg = RubyLLM.config
      if cfg.gemini_api_key.present?
        ENV.fetch("AI_GEMINI_MODEL", "gemini-2.0-flash")
      elsif cfg.openai_api_key.present?
        ENV.fetch("AI_OPENAI_MODEL", "gpt-4o-mini")
      else
        cfg.default_model
      end
    end
  end
end
