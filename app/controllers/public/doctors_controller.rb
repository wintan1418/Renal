class Public::DoctorsController < ApplicationController
  layout "public"

  def index
    @doctors = User.doctors.active.includes(:staff_profile)
  end

  def show
    @doctor = User.doctors.find(params[:id])
    @profile = @doctor.staff_profile
  end
end
