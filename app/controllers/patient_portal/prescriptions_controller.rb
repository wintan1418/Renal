class PatientPortal::PrescriptionsController < PatientPortal::BaseController
  def index
    prescriptions = current_user.prescriptions_as_patient
      .includes(:prescribed_by, :prescription_items)
      .order(created_at: :desc)
    @pagy, @prescriptions = pagy(prescriptions, items: 10)
  end

  def show
    @prescription = current_user.prescriptions_as_patient
      .includes(:prescribed_by, :prescription_items)
      .find(params[:id])
  end
end
