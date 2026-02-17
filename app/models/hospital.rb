class Hospital < ApplicationRecord
  has_one_attached :logo

  validates :name, presence: true

  def self.current
    first_or_create!(name: "Healthroom Renal Centre")
  end
end
