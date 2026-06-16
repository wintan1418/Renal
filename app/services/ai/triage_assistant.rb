module Ai
  # Patient-facing virtual assistant for general kidney-health questions and
  # "should I book?" triage. Multi-turn: the frontend sends recent history.
  # Strictly non-diagnostic; escalates red-flag symptoms to emergency care.
  class TriageAssistant < ApplicationService
    Result = Struct.new(:content, :source, :ai, keyword_init: true) do
      def ai? = ai
    end

    MAX_HISTORY = 10

    def initialize(message, history: [], patient: nil)
      @message = message.to_s.strip
      @history = Array(history).last(MAX_HISTORY)
      @patient = patient
    end

    def call
      return Result.new(content: greeting, source: "assistant", ai: false) if @message.blank?

      if Ai::Client.available?
        response = Ai::Client.chat(system: system_prompt, prompt: build_prompt, temperature: 0.4)
        return Result.new(content: response.content, source: response.model, ai: true) if response.ok? && response.content.present?
      end

      Result.new(content: fallback, source: "assistant", ai: false)
    end

    private

    def system_prompt
      <<~SYS
        You are the Healthroom Renal Centre virtual assistant for patients in
        Nigeria. You give general kidney-health information and help the patient
        decide whether to book an appointment. You DO NOT diagnose, prescribe, or
        replace a doctor, and you never give medication advice.

        If the patient describes red-flag or emergency symptoms (chest pain,
        severe breathlessness, passing little or no urine, confusion, severe
        swelling, or a dangerously high blood pressure), urgently tell them to
        seek emergency care or call the centre right away.

        Be warm and concise (2–4 short paragraphs). When appropriate, suggest
        booking a consultation through the patient portal. If asked something
        outside kidney care, gently redirect.
      SYS
    end

    def build_prompt
      convo = @history.filter_map do |m|
        role = (m["role"] || m[:role]).to_s == "assistant" ? "Assistant" : "Patient"
        content = m["content"] || m[:content]
        "#{role}: #{content}" if content.present?
      end.join("\n")

      [ convo.presence, "Patient: #{@message}", "Assistant:" ].compact.join("\n")
    end

    def fallback
      "Thanks for your message. I can't give medical advice here, but our " \
      "specialists can help. You can book a consultation from your dashboard, " \
      "or call us for anything urgent. If you're having an emergency — severe " \
      "breathlessness, chest pain, or passing no urine — please seek emergency " \
      "care immediately."
    end

    def greeting
      "Hello! I'm the Healthroom assistant. Ask me about kidney health, your " \
      "care, or whether you should book a visit. I'm not a substitute for your doctor."
    end
  end
end
