class Admin::DoctorSchedulesController < Admin::BaseController
  before_action :set_schedule, only: [ :show, :edit, :update, :destroy ]

  def index
    schedules = DoctorSchedule.includes(:doctor).order(:doctor_id, :day_of_week)
    schedules = schedules.where(doctor_id: params[:doctor_id]) if params[:doctor_id].present?
    @doctors = User.doctors.active.order(:first_name, :last_name)
    @pagy, @schedules = pagy(schedules, items: 20)
  end

  def show
    redirect_to edit_admin_doctor_schedule_path(@schedule)
  end

  def new
    @schedule = DoctorSchedule.new
    @doctors = User.doctors.active.order(:first_name, :last_name)
  end

  def create
    @schedule = DoctorSchedule.new(schedule_params)

    if @schedule.save
      redirect_to admin_doctor_schedules_path, notice: "Doctor schedule created successfully."
    else
      @doctors = User.doctors.active.order(:first_name, :last_name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @doctors = User.doctors.active.order(:first_name, :last_name)
  end

  def update
    if @schedule.update(schedule_params)
      redirect_to admin_doctor_schedules_path, notice: "Doctor schedule updated successfully."
    else
      @doctors = User.doctors.active.order(:first_name, :last_name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @schedule.destroy
    redirect_to admin_doctor_schedules_path, notice: "Doctor schedule removed."
  end

  private

  def set_schedule
    @schedule = DoctorSchedule.find(params[:id])
  end

  def schedule_params
    params.require(:doctor_schedule).permit(:doctor_id, :day_of_week, :start_time, :end_time, :slot_duration_minutes, :max_patients, :active)
  end
end
