class TelemedicineSession < ApplicationRecord
  audited
  enum :status, { scheduled: 0, active: 1, completed: 2, cancelled: 3 }, prefix: true

  belongs_to :appointment, optional: true
  belongs_to :patient, class_name: "User"
  belongs_to :doctor, class_name: "User"

  validates :room_id, presence: true, uniqueness: true
  validates :patient, :doctor, presence: true

  scope :upcoming, -> { where(status: :scheduled).where("created_at > ?", Time.current) }
  scope :today, -> { where(status: [:scheduled, :active]).where(created_at: Time.current.all_day) }

  def duration_minutes
    return nil unless started_at && ended_at
    ((ended_at - started_at) / 60).round
  end

  def self.generate_room_id
    "room-#{SecureRandom.hex(8)}"
  end
end
