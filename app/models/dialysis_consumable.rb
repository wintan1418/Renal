class DialysisConsumable < ApplicationRecord
  audited

  enum :category, {
    dialyzer: 0,
    bloodlines: 1,
    needles: 2,
    solutions: 3,
    medications: 4,
    other: 5
  }, prefix: true

  monetize :unit_cost_cents, with_model_currency: :NGN

  validates :name, presence: true
  validates :category, presence: true
  validates :quantity_in_stock, numericality: { greater_than_or_equal_to: 0 }
  validates :reorder_level, numericality: { greater_than_or_equal_to: 0 }
  validates :unit_cost_cents, numericality: { greater_than_or_equal_to: 0 }

  has_many :dialysis_consumable_usages, dependent: :restrict_with_error
  has_many :dialysis_sessions, through: :dialysis_consumable_usages

  scope :active, -> { where(active: true) }
  scope :low_stock, -> { where("quantity_in_stock <= reorder_level") }
  scope :by_category, ->(cat) { where(category: cat) }

  def low_stock?
    quantity_in_stock <= reorder_level
  end

  def unit_cost_naira
    unit_cost_cents / 100.0
  end
end
