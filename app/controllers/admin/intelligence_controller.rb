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
      # The AI briefing is loaded lazily via a Turbo frame (see #briefing) so the
      # page renders instantly instead of blocking on the LLM call.
    end

    # Lazy-loaded Turbo frame: computes (and caches) the AI clinical briefing.
    def briefing
      @patient = User.where(role: :patient).find(params[:id])
      analysis = Intelligence::CkdRiskAnalyzer.call(@patient)
      fingerprint = [
        @patient.updated_at.to_i,
        LabResult.where(patient_id: @patient.id).maximum(:updated_at).to_i
      ].join("-")

      briefing = resilient_cache("ai/briefing/#{@patient.id}/#{fingerprint}", expires_in: 12.hours) do
        result = Ai::ClinicalBriefing.call(@patient, analysis: analysis)
        { content: result.content, source: result.ai? ? "AI · #{result.source}" : "rule-based" }
      end
      @briefing = briefing[:content]
      @briefing_source = briefing[:source]
      render :briefing, layout: false
    end
  end
end
