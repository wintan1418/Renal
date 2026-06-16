module PatientPortal
  class AssistantController < PatientPortal::BaseController
    def index; end

    # POST /patient_portal/assistant/message (JSON)
    def message
      result = Ai::TriageAssistant.call(
        params[:message],
        history: params[:history] || [],
        patient: current_user
      )
      render json: { reply: result.content, source: result.ai? ? "AI · #{result.source}" : "assistant" }
    end
  end
end
