class Admin::PatientSurveysController < Admin::BaseController
  before_action :set_survey, only: [:show, :destroy]

  def index
    @surveys = PatientSurvey.includes(:patient, :visit).recent
    @pagy, @surveys = pagy(@surveys)
    @average_rating = PatientSurvey.average_rating
  end

  def show; end

  def destroy
    @survey.destroy
    redirect_to admin_patient_surveys_path, notice: "Survey removed."
  end

  private

  def set_survey
    @survey = PatientSurvey.find(params[:id])
  end
end
