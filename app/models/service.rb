class Service < ApplicationRecord
  belongs_to :department, optional: true

  has_many :appointments
  has_many :recurring_schedules

  enum :service_type, { consultation: 0, procedure: 1, lab_test: 2, dialysis: 3, other: 4 }

  validates :name, presence: true
  monetize :price_cents, as: "price", with_currency: :ngn

  scope :active, -> { where(active: true) }

  audited
end
