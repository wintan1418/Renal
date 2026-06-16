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
    end
  end
end
