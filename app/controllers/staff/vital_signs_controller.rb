class Staff::VitalSignsController < Staff::BaseController
  before_action :set_patient

  def new
    @vital_sign = VitalSign.new(patient: @patient, recorded_by: current_user, recorded_at: Time.current)
    @visit = Visit.find(params[:visit_id]) if params[:visit_id]
  end

  def create
    @vital_sign = VitalSign.new(vital_sign_params.merge(patient: @patient, recorded_by: current_user))
    @vital_sign.recorded_at ||= Time.current

    if @vital_sign.save
      if @vital_sign.visit
        redirect_to staff_patient_visit_path(@patient, @vital_sign.visit), notice: "Vitals recorded."
      else
        redirect_to chart_staff_patient_path(@patient, tab: "vitals"), notice: "Vitals recorded."
      end
    else
      @visit = @vital_sign.visit
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_patient
    @patient = User.find(params[:patient_id])
  end

  def vital_sign_params
    params.require(:vital_sign).permit(:visit_id, :measurement_type, :systolic_bp, :diastolic_bp,
      :heart_rate, :temperature, :weight_kg, :height_cm, :respiratory_rate,
      :oxygen_saturation, :blood_sugar, :recorded_at)
  end
end
