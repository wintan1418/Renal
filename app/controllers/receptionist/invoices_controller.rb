class Receptionist::InvoicesController < Receptionist::BaseController
  before_action :set_invoice, only: [ :show, :edit, :update, :destroy, :send_invoice ]

  def index
    @invoices = Invoice.includes(:patient, :visit).order(created_at: :desc)
    @invoices = @invoices.where(status: params[:status]) if params[:status].present?
    @pagy, @invoices = pagy(@invoices)
  end

  def show
    @payments = @invoice.payments.order(created_at: :desc)
    @insurance_claims = @invoice.insurance_claims
  end

  def new
    @invoice = Invoice.new
    @invoice.invoice_items.build
    @patients = User.where(role: :patient).order(:last_name)
    @services = Service.active.order(:name)
  end

  def create
    @invoice = Invoice.new(invoice_params)
    if @invoice.save
      redirect_to receptionist_invoice_path(@invoice), notice: "Invoice created."
    else
      @patients = User.where(role: :patient).order(:last_name)
      @services = Service.active.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @patients = User.where(role: :patient).order(:last_name)
    @services = Service.active.order(:name)
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to receptionist_invoice_path(@invoice), notice: "Invoice updated."
    else
      @patients = User.where(role: :patient).order(:last_name)
      @services = Service.active.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @invoice.destroy
    redirect_to receptionist_invoices_path, notice: "Invoice deleted."
  end

  def send_invoice
    @invoice.update!(status: :sent)
    redirect_to receptionist_invoice_path(@invoice), notice: "Invoice sent to patient."
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(
      :patient_id, :visit_id, :status, :discount_cents, :tax_cents, :due_date, :notes,
      invoice_items_attributes: [ :id, :service_id, :description, :quantity, :unit_price_cents, :_destroy ]
    )
  end
end
