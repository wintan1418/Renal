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
    reference = "HR-#{SecureRandom.alphanumeric(12).upcase}"
    payment = @invoice.payments.create!(
      patient: current_user,
      amount_cents: @invoice.balance_due_cents,
      payment_method: :paystack,
      status: :pending,
      paystack_reference: reference
    )

    result = Billing::PaystackService.call(
      action: :initialize_transaction,
      email: current_user.email,
      amount_cents: payment.amount_cents,
      reference: reference,
      callback_url: patient_portal_payments_callback_url,
      metadata: { invoice_id: @invoice.id, payment_id: payment.id }
    )

    if result.success?
      redirect_to result.data["authorization_url"], allow_other_host: true
    else
      payment.destroy
      redirect_to pay_patient_portal_invoice_path(@invoice), alert: "Payment initialization failed: #{result.error}"
    end
  end

  private

  def set_invoice
    @invoice = current_user.invoices_as_patient.find(params[:id])
  end
end
