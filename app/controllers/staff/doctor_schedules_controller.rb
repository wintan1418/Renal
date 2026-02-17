class Staff::DoctorSchedulesController < Staff::BaseController
  before_action :set_schedule, only: [ :update, :destroy ]

  def index
    @schedules = current_user.doctor_schedules.order(:day_of_week)
    @schedule = DoctorSchedule.new(doctor: current_user)
  end

  def create
    @schedule = current_user.doctor_schedules.build(schedule_params)

    if @schedule.save
      redirect_to staff_doctor_schedules_path, notice: "Schedule slot added successfully."
    else
      @schedules = current_user.doctor_schedules.order(:day_of_week)
      flash.now[:alert] = @schedule.errors.full_messages.join(", ")
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @schedule.update(schedule_params)
      redirect_to staff_doctor_schedules_path, notice: "Schedule slot updated successfully."
    else
      @schedules = current_user.doctor_schedules.order(:day_of_week)
      flash.now[:alert] = @schedule.errors.full_messages.join(", ")
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @schedule.destroy
    redirect_to staff_doctor_schedules_path, notice: "Schedule slot removed."
  end

  private

  def set_schedule
    @schedule = current_user.doctor_schedules.find(params[:id])
  end

  def schedule_params
    params.require(:doctor_schedule).permit(:day_of_week, :start_time, :end_time, :slot_duration_minutes, :max_patients, :active)
  end
end
