class Staff::DialysisSessionsController < Staff::BaseController
  before_action :set_session, only: [:show, :edit, :update, :start, :complete, :assign_resources]

  def index
    @sessions = DialysisSession.includes(:patient, :doctor, :dialysis_machine, :dialysis_station)
    @sessions = @sessions.where(session_date: params[:date]) if params[:date].present?
    @sessions = @sessions.where(status: params[:status]) if params[:status].present?
    @sessions = @sessions.order(session_date: :desc, created_at: :desc)
    @pagy, @sessions = pagy(@sessions)
  end

  def board
    @today_sessions = DialysisSession.today
      .includes(:patient, :doctor, :nurse, :dialysis_machine, :dialysis_station)
      .order(:start_time)
    @stations = DialysisStation.all.order(:name)
    @machines = DialysisMachine.active.order(:name)
  end

  def show
  end

  def new
    @session = DialysisSession.new(session_date: Date.current)
    @patients = User.where(role: :patient).includes(:patient_profile).order(:last_name)
    @doctors = User.where(role: :doctor).order(:last_name)
    @nurses = User.where(role: :nurse).order(:last_name)
    @machines = DialysisMachine.available.order(:name)
    @stations = DialysisStation.available.order(:name)
  end

  def create
    @session = DialysisSession.new(session_params)
    if @session.save
      redirect_to staff_dialysis_session_path(@session), notice: "Dialysis session scheduled."
    else
      @patients = User.where(role: :patient).includes(:patient_profile).order(:last_name)
      @doctors = User.where(role: :doctor).order(:last_name)
      @nurses = User.where(role: :nurse).order(:last_name)
      @machines = DialysisMachine.available.order(:name)
      @stations = DialysisStation.available.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @patients = User.where(role: :patient).includes(:patient_profile).order(:last_name)
    @doctors = User.where(role: :doctor).order(:last_name)
    @nurses = User.where(role: :nurse).order(:last_name)
    @machines = DialysisMachine.active.order(:name)
    @stations = DialysisStation.all.order(:name)
  end

  def update
    if @session.update(session_params)
      redirect_to staff_dialysis_session_path(@session), notice: "Session updated."
    else
      @patients = User.where(role: :patient).includes(:patient_profile).order(:last_name)
      @doctors = User.where(role: :doctor).order(:last_name)
      @nurses = User.where(role: :nurse).order(:last_name)
      @machines = DialysisMachine.active.order(:name)
      @stations = DialysisStation.all.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def start
    result = Dialysis::StartSessionService.call(session: @session)
    if result.success?
      redirect_to staff_dialysis_session_path(@session), notice: "Session started."
    else
      redirect_to staff_dialysis_session_path(@session), alert: result.error
    end
  end

  def complete
    permitted = params.require(:dialysis_session).permit(
      :post_weight_kg, :post_systolic_bp, :post_diastolic_bp, :post_heart_rate,
      :post_temperature, :fluid_removed_ml, :complications, :nursing_notes,
      :patient_tolerated_well
    )
    result = Dialysis::CompleteSessionService.call(session: @session, params: permitted)
    if result.success?
      redirect_to staff_dialysis_session_path(@session), notice: "Session completed."
    else
      redirect_to staff_dialysis_session_path(@session), alert: result.error
    end
  end

  def assign_resources
    result = Dialysis::AssignResourcesService.call(
      session: @session,
      machine_id: params[:dialysis_machine_id],
      station_id: params[:dialysis_station_id]
    )
    if result.success?
      redirect_to staff_dialysis_session_path(@session), notice: "Resources assigned."
    else
      redirect_to staff_dialysis_session_path(@session), alert: result.error
    end
  end

  private

  def set_session
    @session = DialysisSession.find(params[:id])
  end

  def session_params
    params.require(:dialysis_session).permit(
      :patient_id, :doctor_id, :nurse_id, :appointment_id,
      :dialysis_machine_id, :dialysis_station_id,
      :session_type, :session_date, :start_time,
      :access_type, :dry_weight_kg, :target_fluid_removal_ml,
      :blood_flow_rate, :dialysate_flow_rate, :dialysate_composition, :heparin_dose_units,
      :pre_weight_kg, :pre_systolic_bp, :pre_diastolic_bp, :pre_heart_rate, :pre_temperature,
      :nursing_notes
    )
  end
end
