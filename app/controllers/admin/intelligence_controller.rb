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

      briefing = Ai::ClinicalBriefing.call(@patient, analysis: @analysis, diet: @diet, med_safety: @med_safety)
      @briefing = briefing.content
      @briefing_source = briefing.ai? ? "AI · #{briefing.source}" : "rule-based"
    end
  end
end
