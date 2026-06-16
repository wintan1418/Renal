module Ai
  # Clinician-facing one-paragraph briefing for a patient, grounded strictly in
  # the structured intelligence data. Falls back to the deterministic CKD
  # summary when no LLM key is configured.
  class ClinicalBriefing < Base
    def initialize(patient, analysis: nil, diet: nil, med_safety: nil)
      @patient = patient
      @analysis = analysis || Intelligence::CkdRiskAnalyzer.call(patient)
      @diet = diet || Intelligence::DietAnalyzer.call(patient)
      @meds = med_safety || Intelligence::MedicationSafety.call(patient)
    end

    private

    def temperature = 0.2

    def system_prompt
      <<~SYS
        You are a renal-care clinical decision-support assistant for a nephrology
        hospital in Nigeria. Write a concise briefing for the treating clinician
        based ONLY on the structured data provided — never invent values or
        diagnoses. Use 4–6 sentences covering risk trajectory, medication-safety
        issues and dietary concerns, then end with up to 3 short, prioritised
        recommendations as a bullet list. This is decision-support, not a
        diagnosis. Keep it factual and clinical.
      SYS
    end

    def user_prompt
      <<~PROMPT
        PATIENT: #{@patient.full_name}
        CKD stage: #{@analysis.stage&.to_s&.humanize || 'unknown'}
        On dialysis: #{@analysis.on_dialysis ? 'yes' : 'no'}
        Latest eGFR: #{@analysis.latest_egfr&.round(1) || 'n/a'} mL/min/1.73m²
        eGFR trend: #{@analysis.slope_per_year ? "#{@analysis.slope_per_year} mL/min per year" : 'insufficient data'}
        Projected months to ESRD: #{@analysis.projected_months_to_esrd || 'n/a'}
        Risk tier (rule-based): #{@analysis.risk_level}
        Risk factors: #{@analysis.factors.presence&.join('; ') || 'none recorded'}

        MEDICATION SAFETY FLAGS:
        #{@meds[:warnings].any? ? @meds[:warnings].map { |w| "- #{w[:medication]}: #{w[:message]}" }.join("\n") : '- none'}

        DIET (recent daily averages vs renal limits):
        #{diet_lines}
      PROMPT
    end

    def diet_lines
      return "- no diet logs" unless @diet[:available]

      @diet[:metrics].map do |m|
        "- #{m[:label]}: #{m[:daily_avg]}#{m[:unit]} (limit #{m[:limit]}#{m[:unit]})#{' [OVER]' if m[:over]}"
      end.join("\n")
    end

    def fallback
      @analysis.summary
    end
  end
end
