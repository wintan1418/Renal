module Admin
  class IntelligenceController < Admin::BaseController
    def index
      @data = Intelligence::CommandCenter.call
    end

    def show
      @patient = User.where(role: :patient).find(params[:id])
      @analysis = Intelligence::CkdRiskAnalyzer.call(@patient)
      @diet = Intelligence::DietAnalyzer.call(@patient)
      @med_safety = Intelligence::MedicationSafety.call(@patient)

      # Cache the briefing so we don't pay for / wait on an LLM call every view.
      # Invalidated when the patient or their latest lab result changes.
      fingerprint = [
        @patient.updated_at.to_i,
        LabResult.where(patient_id: @patient.id).maximum(:updated_at).to_i
      ].join("-")

      briefing = Rails.cache.fetch("ai/briefing/#{@patient.id}/#{fingerprint}", expires_in: 12.hours) do
        result = Ai::ClinicalBriefing.call(@patient, analysis: @analysis, diet: @diet, med_safety: @med_safety)
        { content: result.content, source: result.ai? ? "AI · #{result.source}" : "rule-based" }
      end
      @briefing = briefing[:content]
      @briefing_source = briefing[:source]
    end
  end
end
