class LabTest < ApplicationRecord
  has_many :lab_results, dependent: :restrict_with_error

  enum :category, {
    renal_function: 0,
    hematology: 1,
    electrolytes: 2,
    urinalysis: 3,
    liver_function: 4,
    lipid_profile: 5,
    serology: 6,
    microbiology: 7,
    other: 8
  }

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }

  scope :active_tests, -> { where(active: true) }
  scope :by_category, ->(cat) { where(category: cat) }

  def normal_range
    return nil unless normal_range_min || normal_range_max
    "#{normal_range_min || '—'} - #{normal_range_max || '—'} #{unit}"
  end

  def price_naira
    price_cents / 100.0
  end
end
