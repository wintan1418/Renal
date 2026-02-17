class PatientPortal::MedicalRecordsController < PatientPortal::BaseController
  def index
    @profile = current_user.patient_profile
    @recent_visits = current_user.visits_as_patient.includes(:doctor).order(visit_date: :desc).limit(5)
    @active_diagnoses = current_user.diagnoses.active_conditions.includes(:diagnosed_by)
    @allergies = current_user.allergies.active_allergies
    @medications = current_user.medications.active_medications
  end
end
