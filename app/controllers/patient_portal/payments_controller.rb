class PatientPortal::PaymentsController < PatientPortal::BaseController
  def index
    @payments = current_user.payments_as_patient.includes(:invoice).order(created_at: :desc)
    @pagy, @payments = pagy(@payments)
  end

  def show
    @payment = current_user.payments_as_patient.find(params[:id])
  end

  def callback
    reference = params[:reference] || params[:trxref]
    payment = Payment.find_by(paystack_reference: reference)

    if payment.nil?
      redirect_to patient_portal_invoices_path, alert: "Payment reference not found."
      return
    end

    result = Billing::PaystackService.call(action: :verify_transaction, reference: reference)

    if result.success?
      payment.update!(status: :successful)
      redirect_to patient_portal_invoice_path(payment.invoice), notice: "Payment successful! Thank you."
    else
      payment.update!(status: :failed)
      redirect_to patient_portal_invoice_path(payment.invoice), alert: "Payment verification failed."
    end
  end
end
