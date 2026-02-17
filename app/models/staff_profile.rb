class StaffProfile < ApplicationRecord
  belongs_to :user
  belongs_to :department, optional: true

  validates :user_id, uniqueness: true

  monetize :consultation_fee_cents, as: "consultation_fee", with_currency: :ngn, allow_nil: true

  audited associated_with: :user
end
