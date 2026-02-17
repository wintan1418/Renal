class DialysisStation < ApplicationRecord
  audited

  enum :station_type, { chair: 0, bed: 1 }, prefix: true
  enum :status, { available: 0, occupied: 1, cleaning: 2, maintenance: 3 }, prefix: true

  validates :name, presence: true
  validates :station_type, :status, presence: true

  has_many :dialysis_sessions, dependent: :restrict_with_error

  scope :available, -> { where(status: :available) }
  scope :occupied, -> { where(status: :occupied) }
end
