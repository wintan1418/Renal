module Intelligence
  # Summarizes a patient's recent diet logs against renal dietary limits and
  # flags risky intake. Runs on the existing DietLog data.
  class DietAnalyzer < ApplicationService
    # Conservative daily ceilings for a renal/dialysis diet.
    LIMITS = {
      sodium_mg: 2000,
      potassium_mg: 2500,
      phosphorus_mg: 1000,
      fluid_intake_ml: 1500,
      protein_g: 90
    }.freeze

    LABELS = {
      sodium_mg: "Sodium",
      potassium_mg: "Potassium",
      phosphorus_mg: "Phosphorus",
      fluid_intake_ml: "Fluid",
      protein_g: "Protein"
    }.freeze

    UNITS = { sodium_mg: "mg", potassium_mg: "mg", phosphorus_mg: "mg", fluid_intake_ml: "ml", protein_g: "g" }.freeze

    def initialize(patient, days: 7)
      @patient = patient
      @days = days
    end

    def call
      logs = DietLog.where(patient_id: @patient.id).where("log_date >= ?", @days.days.ago.to_date)
      return { available: false, metrics: [], alerts: [] } if logs.empty?

      day_count = logs.distinct.count(:log_date).clamp(1, @days)
      metrics = LIMITS.map do |field, limit|
        total = logs.sum(field)
        avg = (total.to_f / day_count).round
        {
          key: field, label: LABELS[field], unit: UNITS[field],
          daily_avg: avg, limit: limit,
          pct: ((avg.to_f / limit) * 100).round,
          over: avg > limit
        }
      end

      { available: true, days: day_count, metrics: metrics, alerts: metrics.select { |m| m[:over] } }
    end
  end
end
