class Receptionist::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_receptionist!
  layout "dashboard"

  private

  def require_receptionist!
    unless current_user.receptionist?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
