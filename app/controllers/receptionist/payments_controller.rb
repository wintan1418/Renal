class Receptionist::PaymentsController < Receptionist::BaseController
  def new
    @invoice = Invoice.find(params[:invoice_id])
    @payment = @invoice.payments.new(patient: @invoice.patient)
  end

  def create
    @invoice = Invoice.find(params[:payment][:invoice_id])
    @payment = @invoice.payments.new(payment_params)
    @payment.patient = @invoice.patient
    @payment.status = :successful  # Cash/card payments are instant

    if @payment.save
      redirect_to receptionist_invoice_path(@invoice), notice: "Payment of #{number_to_currency(@payment.amount_cents / 100.0, unit: '₦', separator: '.', delimiter: ',')} recorded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def payment_params
    params.require(:payment).permit(:invoice_id, :amount_cents, :payment_method, :notes)
  end
end
