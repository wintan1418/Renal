class PatientPortal::MessagesController < PatientPortal::BaseController
  def create
    @conversation = current_user.conversations.find(params[:conversation_id])
    result = Messages::CreateService.call(
      conversation: @conversation,
      sender: current_user,
      body: params.dig(:message, :body)
    )

    if result.success?
      redirect_to patient_portal_conversation_path(@conversation)
    else
      redirect_to patient_portal_conversation_path(@conversation), alert: result.error
    end
  end
end
