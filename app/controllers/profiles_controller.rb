class ProfilesController < ApplicationController
  layout "dashboard"
  before_action :authenticate_user!
  before_action :set_user

  def show
    @profile = role_profile
  end

  def update
    if password_change?
      update_password
    else
      update_account
    end
  end

  private

  def set_user
    @user = current_user
  end

  # Patients edit their PatientProfile; staff edit their StaffProfile.
  def role_profile
    @user.patient? ? @user.patient_profile : @user.staff_profile
  end

  def password_change?
    params.dig(:user, :password).present? || params.dig(:user, :current_password).present?
  end

  def update_account
    @profile = role_profile
    @user.assign_attributes(account_params)
    @profile&.assign_attributes(profile_params)

    ActiveRecord::Base.transaction do
      @user.save!
      @profile&.save!
    end
    redirect_to profile_path, notice: "Profile updated successfully."
  rescue ActiveRecord::RecordInvalid
    messages = (@user.errors.full_messages + Array(@profile&.errors&.full_messages)).to_sentence
    flash.now[:alert] = messages.presence || "Could not update profile."
    render :show, status: :unprocessable_entity
  end

  def update_password
    if @user.update_with_password(password_params)
      bypass_sign_in(@user)
      redirect_to profile_path, notice: "Password changed successfully."
    else
      @profile = role_profile
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :show, status: :unprocessable_entity
    end
  end

  def account_params
    params.require(:user).permit(:first_name, :last_name, :phone, :email, :avatar)
  end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def profile_params
    return {} if params[:profile].blank?

    if @user.patient?
      params.require(:profile).permit(
        :address, :city, :state, :lga, :occupation, :religion,
        :nok_name, :nok_phone, :nok_relationship, :nok_address,
        :insurance_provider, :insurance_policy_number
      )
    else
      params.require(:profile).permit(
        :specialization, :qualification, :bio, :available_for_telemedicine
      )
    end
  end
end
