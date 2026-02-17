class Staff::PrescriptionsController < Staff::BaseController
  before_action :set_patient

  def new
    @prescription = Prescription.new(patient: @patient, prescribed_by: current_user)
    @prescription.prescription_items.build
    @visit = Visit.find(params[:visit_id]) if params[:visit_id]
  end

  def create
    @prescription = Prescription.new(prescription_params.merge(patient: @patient, prescribed_by: current_user, status: :active))
    if @prescription.save
      if @prescription.visit
        redirect_to staff_patient_visit_path(@patient, @prescription.visit), notice: "Prescription created."
      else
        redirect_to chart_staff_patient_path(@patient, tab: "prescriptions"), notice: "Prescription created."
      end
    else
      @visit = @prescription.visit
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @prescription = @patient.prescriptions_as_patient.includes(:prescription_items).find(params[:id])
  end

  private

  def set_patient
    @patient = User.find(params[:patient_id])
  end

  def prescription_params
    params.require(:prescription).permit(:visit_id, :notes,
      prescription_items_attributes: [ :id, :medication_name, :dosage, :frequency, :duration, :route, :quantity, :instructions, :_destroy ])
  end
end
