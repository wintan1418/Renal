module Ai
  # Turns a clinician's rough free-text notes into a structured SOAP note.
  # Returns the formatted text; the fallback simply echoes the notes under a
  # Subjective heading so the doctor can edit manually.
  class ClinicalScribe < Base
    def initialize(notes, context: {})
      @notes = notes.to_s
      @context = context
    end

    # Convenience: returns the note already split into SOAP sections plus the
    # source, used by both the in-form scribe endpoint and server-side save.
    def self.soap(notes, context: {})
      result = call(notes, context: context)
      parse(result.content).merge(source: result.source, ai: result.ai?)
    end

    # The prompt/fallback emit "Subjective:/Objective:/Assessment:/Plan:"
    # headings (markdown-tolerant). Anything before the first heading becomes
    # Subjective.
    def self.parse(text)
      sections = { subjective: "", objective: "", assessment: "", plan: "" }
      current = :subjective
      headings = {
        /\Asubjective:/i => :subjective, /\Aobjective:/i => :objective,
        /\Aassessment:/i => :assessment, /\Aplan:/i => :plan
      }

      text.to_s.each_line do |raw|
        line = raw.gsub("**", "").gsub(/\A\s*#+\s*/, "").gsub(/\A\s*[-*]\s+/, "")
        stripped = line.strip
        if (match = headings.find { |re, _| stripped.match?(re) })
          current = match.last
          rest = stripped.sub(/\A[a-z]+:/i, "").strip
          sections[current] << "#{rest}\n" unless rest.empty?
        else
          sections[current] << line.gsub("**", "")
        end
      end

      sections.transform_values(&:strip)
    end

    private

    def temperature = 0.2

    def system_prompt
      <<~SYS
        You are a medical scribe for a nephrology clinic. Convert the clinician's
        rough notes into a clean, structured SOAP note with exactly these four
        plain-text headings, each on its own line: "Subjective:", "Objective:",
        "Assessment:", "Plan:". Do NOT use markdown, asterisks, bold, or numbered
        headings — the headings must be exactly those words followed by a colon.
        Preserve all clinical facts, never invent vitals or values that aren't
        present, and keep it concise. Output only the SOAP note.
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
