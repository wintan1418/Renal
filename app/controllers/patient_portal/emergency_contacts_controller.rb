class PatientPortal::EmergencyContactsController < PatientPortal::BaseController
  before_action :set_contact, only: [:edit, :update, :destroy]

  def index
    @contacts = current_user.emergency_contacts.primary_first
  end

  def new
    @contact = EmergencyContact.new
  end

  def create
    @contact = current_user.emergency_contacts.build(contact_params)
    if @contact.save
      redirect_to patient_portal_emergency_contacts_path, notice: "Emergency contact added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @contact.update(contact_params)
      redirect_to patient_portal_emergency_contacts_path, notice: "Contact updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy
    redirect_to patient_portal_emergency_contacts_path, notice: "Contact removed."
  end

  private

  def set_contact
    @contact = current_user.emergency_contacts.find(params[:id])
  end

  def contact_params
    params.require(:emergency_contact).permit(:name, :phone, :relationship, :is_primary)
  end
end
