class PatientPortal::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_patient!
  layout "dashboard"

  private

  def require_patient!
    unless current_user.patient?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
