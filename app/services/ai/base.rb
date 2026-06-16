module Ai
  # Base for every AI feature. Subclasses implement #system_prompt,
  # #user_prompt and #fallback. If a provider key is configured and the call
  # succeeds, the model's answer is returned; otherwise the deterministic
  # fallback is used — so the feature always returns something useful.
  class Base < ApplicationService
    Result = Struct.new(:content, :source, :ai, keyword_init: true) do
      def ai? = ai
    end

    def call
      if Ai::Client.available?
        response = Ai::Client.chat(
          system: system_prompt,
          prompt: user_prompt,
          temperature: temperature
        )
        if response.ok? && response.content.present?
          return Result.new(content: response.content, source: response.model, ai: true)
        end
      end

      Result.new(content: fallback, source: "rule-based", ai: false)
    end

    private

    def temperature = 0.3

    def system_prompt = raise(NotImplementedError, "#{self.class} must implement #system_prompt")
    def user_prompt   = raise(NotImplementedError, "#{self.class} must implement #user_prompt")
    def fallback      = raise(NotImplementedError, "#{self.class} must implement #fallback")
  end
end
