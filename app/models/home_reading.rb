class HomeReading < ApplicationRecord
  belongs_to :patient, class_name: "User"

  validates :recorded_on, presence: true
  validates :systolic_bp, :diastolic_bp, :pulse,
            numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :weight_kg, numericality: { greater_than: 0 }, allow_nil: true

  scope :recent, -> { order(recorded_on: :desc, created_at: :desc) }
  scope :since, ->(date) { where("recorded_on >= ?", date) }

  # Blood-pressure severity for flagging to the care team.
  def bp_level
    return nil unless systolic_bp && diastolic_bp
    if systolic_bp >= 180 || diastolic_bp >= 110 then :critical
    elsif systolic_bp >= 140 || diastolic_bp >= 90 then :high
    elsif systolic_bp < 90 || diastolic_bp < 60 then :low
    else :normal
    end
  end

  def bp = (systolic_bp && diastolic_bp) ? "#{systolic_bp}/#{diastolic_bp}" : nil
  def flagged? = %i[high critical low].include?(bp_level)

  # Medication-adherence rate (% of check-ins with meds taken) over a window.
  def self.adherence_rate(scope = all)
    total = scope.count
    return nil if total.zero?
    ((scope.where(meds_taken: true).count.to_f / total) * 100).round
  end
end
