class Public::ContactController < ApplicationController
  layout "public"

  def new
    @contact = ContactSubmission.new
  end

  def create
    @contact = ContactSubmission.new(contact_params)
    if @contact.save
      redirect_to contact_path, notice: "Thank you! We'll get back to you soon."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact_submission).permit(:name, :email, :phone, :subject, :message)
  end
end
