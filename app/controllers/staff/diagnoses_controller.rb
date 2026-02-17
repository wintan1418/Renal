class Staff::DiagnosesController < Staff::BaseController
  before_action :set_patient

  def new
    @diagnosis = Diagnosis.new(patient: @patient, diagnosed_by: current_user)
    @visit = Visit.find(params[:visit_id]) if params[:visit_id]
  end

  def create
    @diagnosis = Diagnosis.new(diagnosis_params.merge(patient: @patient, diagnosed_by: current_user))
    if @diagnosis.save
      redirect_back_or(notice: "Diagnosis recorded.")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @diagnosis = @patient.diagnoses.find(params[:id])
  end

  def update
    @diagnosis = @patient.diagnoses.find(params[:id])
    if @diagnosis.update(diagnosis_params)
      redirect_back_or(notice: "Diagnosis updated.")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_patient
    @patient = User.find(params[:patient_id])
  end

  def redirect_back_or(notice:)
    if @diagnosis.visit
      redirect_to staff_patient_visit_path(@patient, @diagnosis.visit), notice: notice
    else
      redirect_to chart_staff_patient_path(@patient, tab: "diagnoses"), notice: notice
    end
  end

  def diagnosis_params
    params.require(:diagnosis).permit(:visit_id, :icd_code, :description, :diagnosis_type, :status, :onset_date, :resolved_date, :notes)
  end
end
