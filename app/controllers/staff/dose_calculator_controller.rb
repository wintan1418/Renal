module Staff
  class DoseCalculatorController < Staff::BaseController
    def index
      @drugs = Clinical::RenalDoseCalculator.drug_names
      @patients = User.where(role: :patient).order(:first_name)
      @drug = params[:drug]
      @egfr = params[:egfr].presence

      # If a patient is chosen, default the eGFR to their latest result.
      if params[:patient_id].present?
        @patient = User.find_by(id: params[:patient_id])
        @egfr ||= latest_egfr(@patient)&.to_s
      end

      @result = Clinical::RenalDoseCalculator.call(drug: @drug, egfr: @egfr) if @drug.present?
    end

    private

    def latest_egfr(patient)
      return nil unless patient
      LabResult.joins(:lab_test)
               .where(patient_id: patient.id, lab_tests: { code: "EGFR" })
               .where.not(numeric_value: nil)
               .order(:result_date).last&.numeric_value
    end
  end
end
