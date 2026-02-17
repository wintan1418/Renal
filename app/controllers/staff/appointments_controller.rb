class Staff::AppointmentsController < Staff::BaseController
  before_action :set_appointment, only: [ :show, :update, :start, :complete ]

  def index
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @appointments = current_user.appointments_as_doctor
      .includes(:patient, :service, :department)
      .where(scheduled_date: @date)
      .order(:queue_number, :start_time)
  end

  def show
  end

  def update
    if @appointment.update(appointment_params)
      redirect_to staff_appointment_path(@appointment), notice: "Appointment updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def start
    if @appointment.checked_in? || @appointment.confirmed?
      @appointment.update(status: :in_progress)
      redirect_to staff_appointments_path(date: @appointment.scheduled_date), notice: "Appointment started."
    else
      redirect_to staff_appointments_path(date: @appointment.scheduled_date), alert: "Cannot start this appointment. Patient must be checked in first."
    end
  end

  def complete
    if @appointment.in_progress?
      @appointment.update(status: :completed)
      redirect_to staff_appointments_path(date: @appointment.scheduled_date), notice: "Appointment completed."
    else
      redirect_to staff_appointments_path(date: @appointment.scheduled_date), alert: "Cannot complete this appointment."
    end
  end

  private

  def set_appointment
    @appointment = current_user.appointments_as_doctor.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:notes)
  end
end
