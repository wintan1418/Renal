class DialysisConsumableUsage < ApplicationRecord
  belongs_to :dialysis_session
  belongs_to :dialysis_consumable

  validates :quantity_used, presence: true,
            numericality: { greater_than: 0 }

  after_create :deduct_stock

  private

  def deduct_stock
    dialysis_consumable.decrement!(:quantity_in_stock, quantity_used)
  end
end
