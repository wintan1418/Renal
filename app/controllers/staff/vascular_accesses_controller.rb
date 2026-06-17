module Staff
  class VascularAccessesController < Staff::BaseController
    before_action :set_patient

    def create
      @patient.vascular_accesses.create(access_params)
      redirect_to chart_staff_patient_path(@patient, tab: "demographics"), notice: "Vascular access recorded."
    end

    def update
      access = @patient.vascular_accesses.find(params[:id])
      access.update(access_params)
      redirect_to chart_staff_patient_path(@patient, tab: "demographics"), notice: "Vascular access updated."
    end

    private

    def set_patient
      @patient = User.where(role: :patient).find(params[:patient_id])
    end

    def access_params
      params.require(:vascular_access).permit(:access_type, :location, :created_on, :status, :last_assessed_on, :notes)
    end
  end
end
