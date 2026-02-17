class Admin::ContactSubmissionsController < Admin::BaseController
  before_action :set_contact_submission, only: [ :show, :update ]

  def index
    submissions = ContactSubmission.all
    submissions = submissions.where(status: params[:status]) if params[:status].present?
    submissions = submissions.where("name ILIKE :q OR email ILIKE :q OR subject ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
    @pagy, @contact_submissions = pagy(submissions.order(created_at: :desc), items: 20)
  end

  def show
    @contact_submission.read! if @contact_submission.unread?
  end

  def update
    if @contact_submission.update(contact_submission_params)
      @contact_submission.update(responded_by: current_user) if @contact_submission.responded?
      redirect_to admin_contact_submission_path(@contact_submission), notice: "Submission updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_contact_submission
    @contact_submission = ContactSubmission.find(params[:id])
  end

  def contact_submission_params
    params.require(:contact_submission).permit(:status, :response_notes)
  end
end
