module Messages
  class CreateService < ApplicationService
    def initialize(conversation:, sender:, body:)
      @conversation = conversation
      @sender = sender
      @body = body
    end

    def call
      message = @conversation.messages.build(sender: @sender, body: @body)

      if message.save
        # Notify other participants
        @conversation.participants.where.not(id: @sender.id).each do |participant|
          Notifications::DispatchService.call(
            recipient: participant,
            actor: @sender,
            action: "new_message",
            title: "New message from #{@sender.full_name}",
            body: @body.truncate(100),
            notifiable: @conversation
          )
        end

        Result.new(success?: true, data: message)
      else
        Result.new(success?: false, error: message.errors.full_messages.join(", "))
      end
    end
  end
end
