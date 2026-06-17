module PatientPortal
  class TelemedicineSessionsController < PatientPortal::BaseController
    def index
      @sessions = current_user.telemedicine_sessions_as_patient
        .includes(:doctor).order(created_at: :desc)
    end

    def show
      @session = current_user.telemedicine_sessions_as_patient.find(params[:id])
    end
  end
end
