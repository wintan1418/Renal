class Receptionist::AppointmentsController < Receptionist::BaseController
  before_action :set_appointment, only: [ :show, :edit, :update, :check_in, :cancel ]

  def index
    @date = params[:date].present? ? Date.parse(params[:date]) : nil
    appointments = Appointment.includes(:patient, :doctor, :service, :department)
    appointments = appointments.where(scheduled_date: @date) if @date.present?
    appointments = appointments.where("users.first_name ILIKE :q OR users.last_name ILIKE :q", q: "%#{params[:q]}%").joins(:patient) if params[:q].present?
    appointments = appointments.where(status: params[:status]) if params[:status].present?
    @pagy, @appointments = pagy(appointments.order(scheduled_date: :desc, start_time: :asc), items: 20)
  end

  def new
    @appointment = Appointment.new(scheduled_date: Date.current, appointment_type: :walk_in)
    @doctors = User.doctors.active.includes(:staff_profile)
    @patients = User.where(role: :patient).active.order(:first_name, :last_name)
    @services = Service.active.order(:name)
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.appointment_type = :walk_in if @appointment.appointment_type.blank?
    @appointment.status = :confirmed

    if @appointment.save
      redirect_to receptionist_appointment_path(@appointment), notice: "Appointment created successfully."
    else
      @doctors = User.doctors.active.includes(:staff_profile)
      @patients = User.where(role: :patient).active.order(:first_name, :last_name)
      @services = Service.active.order(:name)
      flash.now[:alert] = @appointment.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
    @doctors = User.doctors.active.includes(:staff_profile)
    @services = Service.active.order(:name)
  end

  def update
    if @appointment.update(appointment_params)
      redirect_to receptionist_appointment_path(@appointment), notice: "Appointment updated successfully."
    else
      @doctors = User.doctors.active.includes(:staff_profile)
      @services = Service.active.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def check_in
    if defined?(Appointments::CheckInService)
      result = Appointments::CheckInService.new(@appointment, current_user).call
      if result
        redirect_to receptionist_appointment_path(@appointment), notice: "Patient checked in successfully."
      else
        redirect_to receptionist_appointment_path(@appointment), alert: "Unable to check in this patient."
      end
    else
      if @appointment.pending? || @appointment.confirmed?
        @appointment.update(status: :checked_in, checked_in_by: current_user, checked_in_at: Time.current)
        redirect_to receptionist_appointment_path(@appointment), notice: "Patient checked in successfully."
      else
        redirect_to receptionist_appointment_path(@appointment), alert: "Unable to check in this patient."
      end
    end
  end

  def cancel
    if @appointment.pending? || @appointment.confirmed?
      @appointment.update(status: :cancelled)
      redirect_to receptionist_appointments_path, notice: "Appointment cancelled."
    else
      redirect_to receptionist_appointment_path(@appointment), alert: "Unable to cancel this appointment."
    end
  end

  def today
    @appointments = Appointment.includes(:patient, :doctor, :service, :department)
      .where(scheduled_date: Date.current)
      .order(:start_time, :queue_number)
    @doctors = User.doctors.active.includes(:staff_profile)
  end

  def queue
    @doctors = User.doctors.active.includes(:staff_profile).order(:first_name)
    @doctor_id = params[:doctor_id]
    appointments = Appointment.includes(:patient, :doctor, :service)
      .where(scheduled_date: Date.current)
      .where(status: [ :confirmed, :checked_in, :in_progress ])
      .order(:queue_number)
    appointments = appointments.where(doctor_id: @doctor_id) if @doctor_id.present?
    @appointments = appointments
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:patient_id, :doctor_id, :service_id, :scheduled_date, :start_time, :reason, :appointment_type, :notes)
  end
end
