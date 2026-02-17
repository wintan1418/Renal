class PatientPortal::DialysisHistoryController < PatientPortal::BaseController
  def index
    @sessions = current_user.dialysis_sessions_as_patient
      .includes(:doctor, :dialysis_machine, :dialysis_station)
      .order(session_date: :desc)
    @pagy, @sessions = pagy(@sessions)

    # Trend data for charts
    @weight_trend = current_user.dialysis_sessions_as_patient
      .status_completed
      .where.not(pre_weight_kg: nil)
      .order(:session_date)
      .last(20)
      .map { |s| [s.session_date.strftime("%b %d"), s.pre_weight_kg.to_f] }

    @fluid_trend = current_user.dialysis_sessions_as_patient
      .status_completed
      .where.not(fluid_removed_ml: nil)
      .order(:session_date)
      .last(20)
      .map { |s| [s.session_date.strftime("%b %d"), s.fluid_removed_ml.to_f] }
  end

  def show
    @session = current_user.dialysis_sessions_as_patient.find(params[:id])
  end
end
