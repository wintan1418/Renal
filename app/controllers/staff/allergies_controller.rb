class Staff::AllergiesController < Staff::BaseController
  before_action :set_patient

  def new
    @allergy = Allergy.new(patient: @patient)
  end

  def create
    @allergy = Allergy.new(allergy_params.merge(patient: @patient))
    if @allergy.save
      redirect_to chart_staff_patient_path(@patient, tab: "diagnoses"), notice: "Allergy recorded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @allergy = @patient.allergies.find(params[:id])
  end

  def update
    @allergy = @patient.allergies.find(params[:id])
    if @allergy.update(allergy_params)
      redirect_to chart_staff_patient_path(@patient, tab: "diagnoses"), notice: "Allergy updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @allergy = @patient.allergies.find(params[:id])
    @allergy.destroy
    redirect_to chart_staff_patient_path(@patient, tab: "diagnoses"), notice: "Allergy removed."
  end

  private

  def set_patient
    @patient = User.find(params[:patient_id])
  end

  def allergy_params
    params.require(:allergy).permit(:allergen, :reaction, :severity, :active, :notes)
  end
end
