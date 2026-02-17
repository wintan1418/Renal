class Payment < ApplicationRecord
  audited

  enum :payment_method, {
    cash: 0, card: 1, paystack: 2, insurance: 3, bank_transfer: 4
  }, prefix: true

  enum :status, { pending: 0, successful: 1, failed: 2, refunded: 3 }, prefix: true

  belongs_to :invoice
  belongs_to :patient, class_name: "User"

  monetize :amount_cents, with_model_currency: :NGN

  validates :amount_cents, numericality: { greater_than: 0 }
  validates :payment_method, presence: true

  after_create :update_invoice_paid_amount

  private

  def update_invoice_paid_amount
    return unless status_successful?
    paid = invoice.payments.status_successful.sum(:amount_cents)
    invoice.update_columns(amount_paid_cents: paid, status: paid >= invoice.total_cents ? 2 : invoice.status_before_type_cast)
  end
end
