class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications_received.recent
    @pagy, @notifications = pagy(@notifications)
  end

  def show
    @notification = current_user.notifications_received.find(params[:id])
    @notification.read!
    redirect_to @notification.notifiable if @notification.notifiable.respond_to?(:to_model)
  rescue
    redirect_to notifications_path
  end

  def mark_read
    @notification = current_user.notifications_received.find(params[:id])
    @notification.read!
    head :ok
  end

  def mark_all_read
    current_user.notifications_received.unread.update_all(read_at: Time.current)
    redirect_to notifications_path, notice: "All notifications marked as read."
  end
end
