class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :service, optional: true

  monetize :unit_price_cents, :total_cents, with_model_currency: :NGN

  validates :description, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }

  before_save :calculate_total

  private

  def calculate_total
    self.total_cents = quantity * unit_price_cents
  end
end
