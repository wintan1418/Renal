class PatientPortal::SurveysController < PatientPortal::BaseController
  def new
    @visit = Visit.find_by(id: params[:visit_id])
    @survey = PatientSurvey.new(visit: @visit)
  end

  def create
    @survey = current_user.patient_surveys.build(survey_params)
    if @survey.save
      redirect_to patient_portal_root_path, notice: "Thank you for your feedback!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def survey_params
    params.require(:patient_survey).permit(:visit_id, :overall_rating, :doctor_rating, :staff_rating, :comments)
  end
end
