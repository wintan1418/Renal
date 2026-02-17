class Admin::ServicesController < Admin::BaseController
  before_action :set_service, only: [ :show, :edit, :update, :destroy ]

  def index
    services = Service.includes(:department)
    services = services.where(department_id: params[:department_id]) if params[:department_id].present?
    services = services.where(service_type: params[:service_type]) if params[:service_type].present?
    services = services.where("name ILIKE :q OR description ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
    @pagy, @services = pagy(services.order(:name), items: 20)
  end

  def show
  end

  def new
    @service = Service.new
  end

  def create
    @service = Service.new(service_params)
    if @service.save
      redirect_to admin_services_path, notice: "Service created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @service.update(service_params)
      redirect_to admin_services_path, notice: "Service updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service.update(active: false)
    redirect_to admin_services_path, notice: "Service deactivated."
  end

  private

  def set_service
    @service = Service.find(params[:id])
  end

  def service_params
    params.require(:service).permit(:department_id, :name, :description, :price_cents, :duration_minutes, :service_type, :active)
  end
end
