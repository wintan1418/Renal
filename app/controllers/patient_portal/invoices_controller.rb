class PatientPortal::InvoicesController < PatientPortal::BaseController
  before_action :set_invoice, only: [ :show, :pay, :initiate_payment ]

  def index
    @invoices = current_user.invoices_as_patient.order(created_at: :desc)
    @pagy, @invoices = pagy(@invoices)
    @balance_due = current_user.invoices_as_patient.sum("total_cents - amount_paid_cents")
  end

  def show
    @payments = @invoice.payments.order(created_at: :desc)
  end

  def pay
    # Show payment page
  end

  def initiate_payment
    # Demo mode: live payment gateways (Paystack, cards) are not yet activated.
    # Record a simulated successful payment so the flow completes end-to-end,
    # then explain that integrations go live at launch.
    amount = @invoice.balance_due_cents
    if amount.positive?
      @invoice.payments.create!(
        patient: current_user,
        amount_cents: amount,
        payment_method: :paystack,
        status: :successful,
        paystack_reference: "DEMO-#{SecureRandom.alphanumeric(10).upcase}",
        notes: "Demo payment — gateway not yet live"
      )
      @invoice.update(amount_paid_cents: @invoice.amount_paid_cents + amount, status: :paid)
    end

    redirect_to patient_portal_invoice_path(@invoice),
      notice: "✅ Demo payment recorded. This is a demonstration — live Paystack and card processing will be activated when the clinic goes live."
  end

  private

  def set_invoice
    @invoice = current_user.invoices_as_patient.find(params[:id])
  end
end
