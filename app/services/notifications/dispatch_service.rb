module Notifications
  class DispatchService < ApplicationService
    def initialize(recipient:, action:, title:, body: nil, actor: nil, notifiable: nil)
      @recipient = recipient
      @action = action
      @title = title
      @body = body
      @actor = actor
      @notifiable = notifiable
    end

    def call
      notification = Notification.create!(
        recipient: @recipient,
        actor: @actor,
        notifiable: @notifiable,
        action: @action,
        title: @title,
        body: @body
      )

      Result.new(success?: true, data: notification)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success?: false, error: e.message)
    end
  end
end
