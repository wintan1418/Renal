class PatientSurvey < ApplicationRecord
  belongs_to :patient, class_name: "User"
  belongs_to :visit, optional: true

  validates :overall_rating, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :doctor_rating, numericality: { only_integer: true, in: 1..5 }, allow_nil: true
  validates :staff_rating, numericality: { only_integer: true, in: 1..5 }, allow_nil: true

  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }

  def self.average_rating
    published.average(:overall_rating).to_f.round(1)
  end
end
