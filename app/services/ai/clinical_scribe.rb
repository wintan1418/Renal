module Ai
  # Turns a clinician's rough free-text notes into a structured SOAP note.
  # Returns the formatted text; the fallback simply echoes the notes under a
  # Subjective heading so the doctor can edit manually.
  class ClinicalScribe < Base
    def initialize(notes, context: {})
      @notes = notes.to_s
      @context = context
    end

    private

    def temperature = 0.2

    def system_prompt
      <<~SYS
        You are a medical scribe for a nephrology clinic. Convert the clinician's
        rough notes into a clean, structured SOAP note with exactly these
        headings: "Subjective:", "Objective:", "Assessment:", "Plan:". Preserve
        all clinical facts, never invent vitals or values that aren't present,
        and keep it concise. Output only the SOAP note.
      SYS
    end

    def user_prompt
      ctx = @context.map { |k, v| "#{k}: #{v}" }.join("\n")
      [ ctx.presence, "Rough notes:\n#{@notes}" ].compact.join("\n\n")
    end

    def fallback
      "Subjective:\n#{@notes}\n\nObjective:\n\nAssessment:\n\nPlan:\n"
    end
  end
end
