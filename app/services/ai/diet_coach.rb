module Ai
  # Friendly, patient-facing dietary coaching based on the patient's recent
  # renal-diet analysis. Falls back to a deterministic tip list when no LLM
  # key is configured.
  class DietCoach < Base
    def initialize(patient, analysis: nil)
      @patient = patient
      @analysis = analysis || Intelligence::DietAnalyzer.call(patient)
    end

    private

    def temperature = 0.4

    def system_prompt
      <<~SYS
        You are a renal dietitian coaching a kidney patient in Nigeria. Using the
        data provided, give warm, practical, culturally relevant advice (reference
        common Nigerian foods where helpful). Focus on the nutrients that are over
        their limit. Be encouraging, never alarmist, and never give medical or
        medication advice. 2–3 short paragraphs followed by up to 4 concrete,
        actionable tips as a bullet list.
      SYS
    end

    def user_prompt
      lines = @analysis[:metrics].map do |m|
        "#{m[:label]}: #{m[:daily_avg]}#{m[:unit]}/day vs limit #{m[:limit]}#{m[:unit]}#{' (OVER)' if m[:over]}"
      end
      <<~PROMPT
        Patient's recent daily averages (last #{@analysis[:days]} days):
        #{lines.join("\n")}

        Over-limit nutrients: #{@analysis[:alerts].map { |m| m[:label] }.presence&.join(', ') || 'none'}
      PROMPT
    end

    def fallback
      over = @analysis[:alerts]
      return "Your intake looks well within renal-diet limits over the past few days — keep it up! Stay consistent with logging so your care team can track trends." if over.empty?

      tips = over.map do |m|
        case m[:key]
        when :sodium_mg then "Cut back on salt, seasoning cubes and processed/tinned foods to lower sodium."
        when :potassium_mg then "Limit high-potassium foods (bananas, oranges, tomatoes, plantain); soak/boil vegetables."
        when :phosphorus_mg then "Reduce dairy, cola and processed foods high in phosphorus."
        when :fluid_intake_ml then "Watch your fluid intake — sip slowly and use ice chips to manage thirst."
        when :protein_g then "Discuss your protein portions with your dietitian."
        else "Review your #{m[:label].downcase} intake."
        end
      end
      "A few of your nutrients were above the recommended renal-diet limits recently. " \
      "Here are some simple steps:\n- #{tips.join("\n- ")}\n\nPlease discuss any diet changes with your care team."
    end
  end
end
