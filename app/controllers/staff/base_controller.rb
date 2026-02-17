class Staff::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_clinical_staff!
  layout "dashboard"

  private

  def require_clinical_staff!
    unless current_user.clinical_staff?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
