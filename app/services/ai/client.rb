module Ai
  # The single point of contact with the LLM provider (RubyLLM → Gemini /
  # OpenAI / OpenRouter). Everything else in app/services/ai goes through here.
  # Never raises — returns a Response so callers can fall back gracefully.
  class Client
    Response = Struct.new(:content, :model, :ok, :error, keyword_init: true) do
      def ok? = ok
    end

    # Preference order. First provider with a configured key wins, unless
    # AI_PROVIDER explicitly names one. OpenAI is first as the reliable default;
    # set AI_PROVIDER=gemini (once billing is enabled) to switch.
    PROVIDERS = [
      { name: "openai",     key: :openai_api_key,     provider: :openai,     env_model: "AI_OPENAI_MODEL",     default: "gpt-4o-mini" },
      { name: "gemini",     key: :gemini_api_key,     provider: :gemini,     env_model: "AI_GEMINI_MODEL",     default: "gemini-2.0-flash" },
      { name: "openrouter", key: :openrouter_api_key, provider: :openrouter, env_model: "AI_OPENROUTER_MODEL", default: "openai/gpt-4o-mini" }
    ].freeze

    class << self
      def available?
        resolve.present?
      rescue StandardError
        false
      end

      # The active provider/model, or nil if no key is configured.
      def resolve
        cfg = RubyLLM.config
        forced = ENV["AI_PROVIDER"].presence
        ordered = forced ? PROVIDERS.sort_by { |p| p[:name] == forced ? 0 : 1 } : PROVIDERS

        ordered.each do |p|
          next unless cfg.public_send(p[:key]).present?

          return { provider: p[:provider], model: ENV.fetch(p[:env_model], p[:default]) }
        end
        nil
      rescue StandardError
        nil
      end

      def chat(system:, prompt:, temperature: 0.3)
        new.chat(system: system, prompt: prompt, temperature: temperature)
      end
    end

    def chat(system:, prompt:, temperature: 0.3)
      target = self.class.resolve
      return Response.new(content: nil, model: nil, ok: false, error: "no provider configured") if target.nil?

      conversation = build_chat(target)
      conversation.with_temperature(temperature) if conversation.respond_to?(:with_temperature)
      conversation.with_instructions(system) if system.present?

      result = conversation.ask(prompt)
      Response.new(content: result.content.to_s.strip, model: target[:model], ok: true)
    rescue StandardError => e
      Rails.logger.error("[Ai::Client] #{e.class}: #{e.message}")
      Response.new(content: nil, model: target && target[:model], ok: false, error: e.message)
    end

    private

    # OpenRouter/Gemini model ids aren't always in RubyLLM's registry, so allow
    # assuming the model exists; fall back to a plain call if the option is
    # unsupported by this gem version.
    def build_chat(target)
      RubyLLM.chat(model: target[:model], provider: target[:provider], assume_model_exists: true)
    rescue ArgumentError
      RubyLLM.chat(model: target[:model], provider: target[:provider])
    rescue StandardError
      RubyLLM.chat(model: target[:model])
    end
  end
end
