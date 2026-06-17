module Intelligence
  # Scores upcoming appointments by no-show risk so the front desk can
  # prioritise confirmation calls. Heuristic model over existing data.
  class NoShowPredictor < ApplicationService
    Prediction = Struct.new(:appointment, :score, :risk, :reasons, keyword_init: true)

    def initialize(limit: 10)
      @limit = limit
    end

    def call
      Appointment
        .where(scheduled_date: Date.current..(Date.current + 30.days))
        .where(status: %i[pending confirmed])
        .includes(:patient, :doctor)
        .map { |appt| predict(appt) }
        .sort_by { |p| -p.score }
        .first(@limit)
    end

    private

    def predict(appt)
      reasons = []
      score = 0.12 # baseline risk

      past = Appointment.where(patient_id: appt.patient_id, status: %i[completed no_show cancelled])
      total = past.count
      no_shows = past.where(status: :no_show).count

      if total >= 2
        rate = no_shows.to_f / total
        score += rate * 0.55
        reasons << "#{(rate * 100).round}% past no-show rate" if no_shows.positive?
      else
        reasons << "Limited visit history"
        score += 0.1
      end

      if appt.status == "pending"
        score += 0.22
        reasons << "Not yet confirmed"
      end

      lead = (appt.scheduled_date - Date.current).to_i
      if lead > 14
        score += 0.1
        reasons << "Booked far in advance"
      end

      balance = Invoice.where(patient_id: appt.patient_id)
                       .where.not(status: %i[draft cancelled])
                       .where("total_cents > amount_paid_cents")
                       .sum("total_cents - amount_paid_cents")
      if balance.positive?
        score += 0.15
        reasons << "Outstanding balance"
      end

      score = [ score, 0.97 ].min
      risk = if score >= 0.5 then :high
      elsif score >= 0.3 then :medium
      else :low
      end

      Prediction.new(appointment: appt, score: (score * 100).round, risk: risk, reasons: reasons)
    end
  end
end
