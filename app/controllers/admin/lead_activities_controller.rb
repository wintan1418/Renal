module Admin
  class LeadActivitiesController < Admin::BaseController
    def create
      @lead = ContactSubmission.find(params[:lead_id])
      activity = @lead.lead_activities.new(activity_params)
      activity.user = current_user

      if activity.save
        # Logging contact advances tracking timestamps.
        @lead.update(last_contacted_at: Time.current) if activity.call? || activity.email? || activity.whatsapp? || activity.meeting?
        redirect_to admin_lead_path(@lead), notice: "Activity logged."
      else
        redirect_to admin_lead_path(@lead), alert: activity.errors.full_messages.to_sentence
      end
    end

    private

    def activity_params
      params.require(:lead_activity).permit(:kind, :body)
    end
  end
end
