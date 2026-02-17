class PatientPortal::DietLogsController < PatientPortal::BaseController
  before_action :set_log, only: [:show, :edit, :update, :destroy]

  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @logs = current_user.diet_logs.for_date(@date).order(:meal_type)
    @daily_fluid = DietLog.daily_fluid_total(current_user, @date)
    @week_logs = current_user.diet_logs.where(log_date: 6.days.ago.to_date..Date.current).order(log_date: :asc)
  end

  def show; end

  def new
    @log = DietLog.new(log_date: Date.current)
  end

  def create
    @log = current_user.diet_logs.build(log_params)
    if @log.save
      redirect_to patient_portal_diet_logs_path, notice: "Diet entry recorded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @log.update(log_params)
      redirect_to patient_portal_diet_logs_path, notice: "Entry updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @log.destroy
    redirect_to patient_portal_diet_logs_path, notice: "Entry removed."
  end

  private

  def set_log
    @log = current_user.diet_logs.find(params[:id])
  end

  def log_params
    params.require(:diet_log).permit(:log_date, :meal_type, :fluid_intake_ml, :sodium_mg, :potassium_mg, :phosphorus_mg, :protein_g, :calories_kcal, :notes)
  end
end
