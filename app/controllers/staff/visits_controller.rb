class Staff::VisitsController < Staff::BaseController
  before_action :set_patient

  def index
    @visits = @patient.visits_as_patient.includes(:doctor).order(visit_date: :desc)
  end

  def new
    @visit = Visit.new(patient: @patient, doctor: current_user, visit_date: Date.current)
    @appointment = Appointment.find(params[:appointment_id]) if params[:appointment_id]
  end

  def create
    if params[:appointment_id].present?
      appointment = Appointment.find(params[:appointment_id])
      if defined?(Visits::CreateFromAppointmentService)
        result = Visits::CreateFromAppointmentService.call(appointment: appointment, doctor: current_user)
        if result.success?
          redirect_to staff_patient_visit_path(@patient, result.data), notice: "Visit started."
        else
          redirect_to staff_patient_path(@patient), alert: result.error
        end
      else
        @visit = Visit.new(
          patient: @patient,
          doctor: current_user,
          appointment: appointment,
          visit_date: appointment.scheduled_date,
          chief_complaint: appointment.reason,
          status: :in_progress
        )
        if @visit.save
          redirect_to staff_patient_visit_path(@patient, @visit), notice: "Visit started."
        else
          redirect_to staff_patient_path(@patient), alert: @visit.errors.full_messages.join(", ")
        end
      end
    else
      @visit = Visit.new(visit_params.merge(patient: @patient, doctor: current_user, status: :in_progress))
      if @visit.save
        redirect_to staff_patient_visit_path(@patient, @visit), notice: "Visit created."
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def show
    @visit = @patient.visits_as_patient.find(params[:id])
    @clinical_notes = @visit.clinical_notes.includes(:author).order(created_at: :desc)
    @vital_signs = @visit.vital_signs.includes(:recorded_by).order(recorded_at: :desc)
    @lab_orders = @visit.lab_orders.includes(:ordered_by, lab_results: :lab_test)
    @prescriptions = @visit.prescriptions.includes(:prescribed_by, :prescription_items)
    @diagnoses = @visit.diagnoses.includes(:diagnosed_by)
  end

  def update
    @visit = @patient.visits_as_patient.find(params[:id])
    if @visit.update(visit_params)
      redirect_to staff_patient_visit_path(@patient, @visit), notice: "Visit updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_patient
    @patient = User.find(params[:patient_id])
  end

  def visit_params
    params.require(:visit).permit(:visit_date, :visit_type, :chief_complaint, :status, :appointment_id)
  end
end
