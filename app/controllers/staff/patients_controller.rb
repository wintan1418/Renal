class Staff::PatientsController < Staff::BaseController
  def index
    patients = User.where(role: :patient).includes(:patient_profile)
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      patients = patients.left_joins(:patient_profile).where(
        "users.first_name ILIKE :q OR users.last_name ILIKE :q OR users.email ILIKE :q OR users.phone ILIKE :q OR patient_profiles.medical_record_number ILIKE :q",
        q: search_term
      )
    end
    @pagy, @patients = pagy(patients.order(created_at: :desc), items: 20)
  end

  def show
    @patient = User.find(params[:id])
    redirect_to chart_staff_patient_path(@patient)
  end

  def chart
    @patient = User.find(params[:id])
    @profile = @patient.patient_profile
    @tab = params[:tab] || "demographics"

    case @tab
    when "visits"
      @visits = @patient.visits_as_patient.includes(:doctor, :appointment).order(visit_date: :desc)
    when "vitals"
      @vital_signs = @patient.vital_signs_as_patient.includes(:recorded_by).order(recorded_at: :desc).limit(20)
    when "labs"
      @lab_orders = @patient.lab_orders_as_patient.includes(:ordered_by, lab_results: :lab_test).order(created_at: :desc)
    when "prescriptions"
      @prescriptions = @patient.prescriptions_as_patient.includes(:prescribed_by, :prescription_items).order(created_at: :desc)
    when "diagnoses"
      @diagnoses = @patient.diagnoses.includes(:diagnosed_by).order(created_at: :desc)
      @allergies = @patient.allergies.order(created_at: :desc)
      @medications = @patient.medications.order(active: :desc, created_at: :desc)
    end
  end
end
