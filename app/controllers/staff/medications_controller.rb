class Staff::MedicationsController < Staff::BaseController
  before_action :set_patient

  def new
    @medication = Medication.new(patient: @patient, prescribed_by: current_user, start_date: Date.current)
  end

  def create
    @medication = Medication.new(medication_params.merge(patient: @patient, prescribed_by: current_user))
    if @medication.save
      redirect_to chart_staff_patient_path(@patient, tab: "diagnoses"), notice: "Medication added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @medication = @patient.medications.find(params[:id])
  end

  def update
    @medication = @patient.medications.find(params[:id])
    if @medication.update(medication_params)
      redirect_to chart_staff_patient_path(@patient, tab: "diagnoses"), notice: "Medication updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_patient
    @patient = User.find(params[:patient_id])
  end

  def medication_params
    params.require(:medication).permit(:name, :dosage, :frequency, :route, :start_date, :end_date, :active, :notes)
  end
end
