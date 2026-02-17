class PatientPortal::AppointmentsController < PatientPortal::BaseController
  before_action :set_appointment, only: [ :show, :cancel ]

  def index
    appointments = current_user.appointments_as_patient.includes(:doctor, :service, :department)
    @upcoming = appointments.where("scheduled_date >= ?", Date.current).order(:scheduled_date, :start_time)
    @past = appointments.where("scheduled_date < ?", Date.current).order(scheduled_date: :desc, start_time: :desc)
  end

  def new
    @appointment = Appointment.new
    @departments = Department.active.joins(services: {}).joins(
      "INNER JOIN staff_profiles ON staff_profiles.department_id = departments.id"
    ).joins(
      "INNER JOIN users ON users.id = staff_profiles.user_id AND users.role = 3 AND users.active = true"
    ).distinct
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.patient = current_user
    @appointment.appointment_type = :scheduled
    @appointment.status = :pending

    if defined?(Appointments::CreateService)
      result = Appointments::CreateService.new(@appointment).call
      if result
        redirect_to patient_portal_appointment_path(@appointment), notice: "Appointment booked successfully."
      else
        load_departments
        flash.now[:alert] = @appointment.errors.full_messages.join(", ")
        render :new, status: :unprocessable_entity
      end
    else
      if @appointment.save
        redirect_to patient_portal_appointment_path(@appointment), notice: "Appointment booked successfully."
      else
        load_departments
        flash.now[:alert] = @appointment.errors.full_messages.join(", ")
        render :new, status: :unprocessable_entity
      end
    end
  end

  def show
  end

  def cancel
    if defined?(Appointments::CancelService)
      result = Appointments::CancelService.new(@appointment, current_user).call
      if result
        redirect_to patient_portal_appointments_path, notice: "Appointment cancelled successfully."
      else
        redirect_to patient_portal_appointment_path(@appointment), alert: "Unable to cancel this appointment."
      end
    else
      if @appointment.pending? || @appointment.confirmed?
        @appointment.update(status: :cancelled)
        redirect_to patient_portal_appointments_path, notice: "Appointment cancelled successfully."
      else
        redirect_to patient_portal_appointment_path(@appointment), alert: "Unable to cancel this appointment."
      end
    end
  end

  # Turbo Frame endpoints for booking wizard
  def doctors_for_department
    @department = Department.find(params[:department_id])
    @doctors = User.doctors.active.joins(:staff_profile).where(staff_profiles: { department_id: @department.id })
    render partial: "doctors_for_department", locals: { doctors: @doctors, department: @department }
  end

  def available_dates
    @doctor = User.doctors.find(params[:doctor_id])
    @schedules = @doctor.doctor_schedules.active
    @available_dates = []

    (Date.current..30.days.from_now.to_date).each do |date|
      schedule = @schedules.find { |s| s.day_of_week == date.wday }
      next unless schedule

      # Check for schedule exceptions
      exception = ScheduleException.where(doctor_id: @doctor.id, exception_date: date).first
      next if exception && !exception.available?

      # Check if there are available slots
      slots = schedule.available_slots(date)
      @available_dates << date if slots.any?
    end

    render partial: "available_dates", locals: { available_dates: @available_dates, doctor: @doctor }
  end

  def available_slots
    @doctor = User.doctors.find(params[:doctor_id])
    date = Date.parse(params[:date])
    schedule = @doctor.doctor_schedules.active.find_by(day_of_week: date.wday)
    @slots = schedule ? schedule.available_slots(date) : []

    render partial: "available_slots", locals: { slots: @slots, doctor: @doctor, date: date }
  end

  private

  def set_appointment
    @appointment = current_user.appointments_as_patient.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(:doctor_id, :service_id, :scheduled_date, :start_time, :reason)
  end

  def load_departments
    @departments = Department.active.joins(services: {}).joins(
      "INNER JOIN staff_profiles ON staff_profiles.department_id = departments.id"
    ).joins(
      "INNER JOIN users ON users.id = staff_profiles.user_id AND users.role = 3 AND users.active = true"
    ).distinct
  end
end
