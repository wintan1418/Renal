class DialysisMachine < ApplicationRecord
  audited

  enum :status, { available: 0, in_use: 1, maintenance: 2, retired: 3 }, prefix: true

  validates :name, presence: true
  validates :serial_number, presence: true, uniqueness: true
  validates :status, presence: true

  has_many :dialysis_sessions, dependent: :restrict_with_error

  scope :active, -> { where.not(status: :retired) }
  scope :available, -> { where(status: :available) }

  def display_name
    "#{name} (#{serial_number})"
  end
end
