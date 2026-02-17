class InsuranceClaim < ApplicationRecord
  audited

  enum :status, {
    submitted: 0, under_review: 1, approved: 2, rejected: 3, paid: 4
  }, prefix: true

  belongs_to :invoice
  belongs_to :patient, class_name: "User"

  monetize :claim_amount_cents, :approved_amount_cents, with_model_currency: :NGN

  validates :provider_name, presence: true
  validates :claim_amount_cents, numericality: { greater_than: 0 }
end
