class Admin::AppointmentsController < Admin::BaseController
  before_action :set_appointment, only: [ :show ]

  def index
    appointments = Appointment.includes(:patient, :doctor, :service, :department)
    appointments = appointments.where(scheduled_date: params[:date]) if params[:date].present?
    appointments = appointments.where(doctor_id: params[:doctor_id]) if params[:doctor_id].present?
    appointments = appointments.where(status: params[:status]) if params[:status].present?
    @doctors = User.doctors.active.order(:first_name, :last_name)
    @pagy, @appointments = pagy(appointments.order(scheduled_date: :desc, start_time: :asc), items: 20)
  end

  def show
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end
end
