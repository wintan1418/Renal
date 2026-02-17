class Receptionist::InsuranceClaimsController < Receptionist::BaseController
  before_action :set_claim, only: [ :show, :edit, :update ]

  def index
    @claims = InsuranceClaim.includes(:patient, :invoice).order(created_at: :desc)
    @pagy, @claims = pagy(@claims)
  end

  def new
    @claim = InsuranceClaim.new
    @claim.invoice_id = params[:invoice_id]
    @invoices = Invoice.where.not(status: [ :paid, :cancelled ]).includes(:patient)
  end

  def create
    @claim = InsuranceClaim.new(claim_params)
    @claim.patient = @claim.invoice&.patient
    @claim.submitted_at = Date.current
    if @claim.save
      redirect_to receptionist_insurance_claims_path, notice: "Insurance claim submitted."
    else
      @invoices = Invoice.where.not(status: [ :paid, :cancelled ]).includes(:patient)
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def edit
    @invoices = Invoice.where.not(status: [ :paid, :cancelled ]).includes(:patient)
  end

  def update
    if @claim.update(claim_params)
      redirect_to receptionist_insurance_claim_path(@claim), notice: "Claim updated."
    else
      @invoices = Invoice.where.not(status: [ :paid, :cancelled ]).includes(:patient)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_claim
    @claim = InsuranceClaim.find(params[:id])
  end

  def claim_params
    params.require(:insurance_claim).permit(
      :invoice_id, :provider_name, :policy_number, :member_id,
      :claim_amount_cents, :approved_amount_cents, :status, :responded_at, :notes
    )
  end
end
