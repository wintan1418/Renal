module Admin
  class LeadsController < Admin::BaseController
    before_action :set_lead, only: [ :show, :update, :move, :draft_reply ]

    def index
      scope = ContactSubmission.all
      scope = scope.where(assigned_to_id: params[:assigned_to]) if params[:assigned_to].present?
      @leads_by_stage = scope.order(created_at: :desc).group_by(&:stage)
      @stages = ContactSubmission.stages.keys
      @staff = User.where(role: %i[admin receptionist nurse doctor]).order(:first_name)
      @stats = {
        open: ContactSubmission.open_pipeline.count,
        due: ContactSubmission.due_followup.count,
        converted: ContactSubmission.converted.count,
        pipeline_value: ContactSubmission.open_pipeline.sum(:estimated_value_cents)
      }
    end

    def show
      @lead.read! if @lead.respond_to?(:unread?) && @lead.unread?
      @activities = @lead.lead_activities.includes(:user).recent
      @staff = User.where(role: %i[admin receptionist nurse doctor]).order(:first_name)
    end

    def update
      if @lead.update(lead_params)
        redirect_to admin_lead_path(@lead), notice: "Lead updated."
      else
        @activities = @lead.lead_activities.includes(:user).recent
        @staff = User.where(role: %i[admin receptionist nurse doctor]).order(:first_name)
        render :show, status: :unprocessable_entity
      end
    end

    # Quick stage change (from the board or detail), logged to the timeline.
    def move
      from = @lead.stage_label
      if @lead.update(stage: params[:stage])
        @lead.update(last_contacted_at: Time.current) if @lead.contacted?
        @lead.lead_activities.create(user: current_user, kind: :stage_change, body: "Moved from #{from} to #{@lead.stage_label}")
      end
      redirect_back fallback_location: admin_leads_path, notice: "Moved to #{@lead.stage_label}."
    end

    # AI-drafted reply to the lead's enquiry (JSON for in-page use).
    def draft_reply
      result = Ai::LeadReplyDrafter.call(@lead)
      render json: { reply: result.content, source: result.ai? ? "AI · #{result.source}" : "template" }
    end

    private

    def set_lead
      @lead = ContactSubmission.find(params[:id])
    end

    def lead_params
      permitted = params.require(:contact_submission).permit(:stage, :assigned_to_id, :follow_up_on, :estimated_value_cents, :source, :response_notes)
      # The form collects naira; store to the kobo.
      if permitted[:estimated_value_cents].present?
        permitted[:estimated_value_cents] = (permitted[:estimated_value_cents].to_f * 100).round
      end
      permitted
    end
  end
end
