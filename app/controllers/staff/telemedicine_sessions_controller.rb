module Staff
  class TelemedicineSessionsController < Staff::BaseController
    before_action :set_session, only: [ :show, :update ]

    def index
      @sessions = current_user.telemedicine_sessions_as_doctor
        .includes(:patient).order(created_at: :desc)
    end

    def new
      @session = TelemedicineSession.new
      @patients = User.where(role: :patient).order(:first_name)
    end

    def create
      @session = TelemedicineSession.new(session_params)
      @session.doctor = current_user
      @session.room_id = TelemedicineSession.generate_room_id
      @session.status = :scheduled
      if @session.save
        redirect_to staff_telemedicine_session_path(@session), notice: "Telemedicine room created."
      else
        @patients = User.where(role: :patient).order(:first_name)
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @session.update(status: :active, started_at: Time.current) if @session.status_scheduled?
    end

    def update
      @session.update(status: :completed, ended_at: Time.current, notes: params.dig(:telemedicine_session, :notes))
      redirect_to staff_telemedicine_sessions_path, notice: "Session ended."
    end

    private

    def set_session
      @session = current_user.telemedicine_sessions_as_doctor.find(params[:id])
    end

    def session_params
      params.require(:telemedicine_session).permit(:patient_id)
    end
  end
end
