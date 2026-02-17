class Invoice < ApplicationRecord
  audited

  enum :status, { draft: 0, sent: 1, paid: 2, overdue: 3, cancelled: 4 }, prefix: true

  belongs_to :patient, class_name: "User"
  belongs_to :visit, optional: true

  has_many :invoice_items, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :insurance_claims, dependent: :destroy

  accepts_nested_attributes_for :invoice_items, allow_destroy: true, reject_if: :all_blank

  monetize :subtotal_cents, :discount_cents, :tax_cents, :total_cents, :amount_paid_cents,
           with_model_currency: :NGN

  validates :invoice_number, presence: true, uniqueness: true
  validates :patient, presence: true

  before_validation :set_invoice_number, on: :create
  before_save :calculate_totals

  scope :unpaid, -> { where.not(status: [ :paid, :cancelled ]) }
  scope :overdue, -> { where(status: :overdue).or(where("due_date < ? AND status NOT IN (?)", Date.current, [ 2, 4 ])) }

  def balance_due_cents
    total_cents - amount_paid_cents
  end

  def paid?
    amount_paid_cents >= total_cents
  end

  def calculate_totals
    self.subtotal_cents = invoice_items.reject(&:marked_for_destruction?).sum(&:total_cents)
    self.total_cents = subtotal_cents - discount_cents + tax_cents
  end

  private

  def set_invoice_number
    year = Date.current.year
    last = Invoice.where("invoice_number LIKE ?", "INV-#{year}-%").order(:invoice_number).last
    seq = last ? last.invoice_number.split("-").last.to_i + 1 : 1
    self.invoice_number = "INV-#{year}-#{seq.to_s.rjust(5, '0')}"
  end
end
