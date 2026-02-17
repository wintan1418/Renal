class Testimonial < ApplicationRecord
  has_one_attached :photo

  validates :patient_name, presence: true
  validates :content, presence: true
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true

  scope :approved, -> { where(approved: true) }
end
