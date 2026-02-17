class PatientPortal::ConversationsController < PatientPortal::BaseController
  before_action :set_conversation, only: [ :show ]

  def index
    @conversations = current_user.conversations_as_patient.includes(:messages).order(updated_at: :desc)
  end

  def show
    @messages = @conversation.messages.chronological.includes(:sender)
    @new_message = Message.new
    # Mark messages from others as read
    @messages.where.not(sender: current_user).where(read_at: nil).update_all(read_at: Time.current)
  end

  def new
    @conversation = Conversation.new
  end

  def create
    @conversation = Conversation.new(conversation_params)
    @conversation.patient = current_user
    if @conversation.save
      @conversation.conversation_participants.create!(user: current_user)
      # Add admins/doctors as participants
      User.where(role: :admin).limit(1).each do |admin|
        @conversation.conversation_participants.find_or_create_by!(user: admin)
      end
      redirect_to patient_portal_conversation_path(@conversation), notice: "Message sent."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:subject)
  end
end
