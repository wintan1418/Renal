module Intelligence
  # Analyzes a patient's kidney-function trajectory from their lab history and
  # projects decline. Pure statistics on existing data — no external service.
  #
  #   result = Intelligence::CkdRiskAnalyzer.call(patient)
  #   result.risk_level   # => :stable | :monitor | :elevated | :critical | :unknown
  #   result.egfr_series  # => [[Date, value], ...] for charting
  #   result.slope_per_year, result.projected_months_to_esrd, result.summary
  class CkdRiskAnalyzer < ApplicationService
    Analysis = Struct.new(
      :risk_level, :latest_egfr, :slope_per_year, :projected_months_to_esrd,
      :egfr_series, :creatinine_series, :stage, :on_dialysis, :summary, :factors,
      keyword_init: true
    )

    ESRD_THRESHOLD = 15.0 # eGFR (mL/min/1.73m²) marking Stage 5 / ESRD

    def initialize(patient)
      @patient = patient
    end

    def call
      egfr  = series_for("EGFR")
      creat = series_for("CREAT")
      profile = @patient.patient_profile

      slope = linear_slope(egfr) # eGFR units per day
      slope_year = slope ? (slope * 365.25).round(1) : nil
      latest = egfr.last&.last
      projection = months_to_esrd(latest, slope)

      Analysis.new(
        risk_level: risk_level(slope_year, latest, profile),
        latest_egfr: latest,
        slope_per_year: slope_year,
        projected_months_to_esrd: projection,
        egfr_series: egfr,
        creatinine_series: creat,
        stage: profile&.ckd_stage,
        on_dialysis: profile&.on_dialysis,
        summary: nil, # set below
        factors: risk_factors(profile)
      ).tap { |a| a.summary = narrative(a) }
    end

    private

    # [[Date, Float], ...] ascending by date for a given lab test code.
    def series_for(code)
      LabResult
        .joins(:lab_test)
        .where(patient_id: @patient.id, lab_tests: { code: code })
        .where.not(numeric_value: nil)
        .order(:result_date)
        .pluck(:result_date, :numeric_value)
        .filter_map { |d, v| [ d, v.to_f ] if d }
    end

    # Ordinary least-squares slope in value-per-day. nil if < 2 points.
    def linear_slope(series)
      return nil if series.size < 2

      xs = series.map { |d, _| d.to_time.to_i / 86_400.0 }
      ys = series.map { |_, v| v }
      n  = xs.size
      mean_x = xs.sum / n
      mean_y = ys.sum / n
      num = xs.zip(ys).sum { |x, y| (x - mean_x) * (y - mean_y) }
      den = xs.sum { |x| (x - mean_x)**2 }
      return nil if den.zero?

      num / den
    end

    def months_to_esrd(latest, slope_per_day)
      return nil if latest.nil? || slope_per_day.nil? || slope_per_day >= 0
      return 0 if latest <= ESRD_THRESHOLD

      days = (latest - ESRD_THRESHOLD) / -slope_per_day
      (days / 30.44).round
    end

    def risk_level(slope_year, latest, profile)
      return :critical if profile&.on_dialysis
      return :unknown  if latest.nil? && profile&.ckd_stage.nil?

      # eGFR < 15 = ESRD; rapid loss is > 5 mL/min/year (KDIGO "rapid progression")
      return :critical if latest && latest < 15
      return :elevated if latest && latest < 30
      return :elevated if slope_year && slope_year <= -5
      return :monitor  if (latest && latest < 60) || (slope_year && slope_year <= -3)

      :stable
    end

    def risk_factors(profile)
      return [] unless profile

      factors = []
      factors << "On maintenance dialysis" if profile.on_dialysis?
      factors << "Diagnosed hypertension" if @patient.diagnoses.where("description ILIKE ?", "%hypertens%").exists?
      factors << "Diabetes history" if @patient.diagnoses.where("description ILIKE ?", "%diabet%").exists?
      factors << "Anaemia (low haemoglobin)" if low_hgb?
      factors
    end

    def low_hgb?
      v = LabResult.joins(:lab_test)
                   .where(patient_id: @patient.id, lab_tests: { code: "HGB" })
                   .where.not(numeric_value: nil)
                   .order(:result_date).last&.numeric_value
      v && v < 11
    end

    def narrative(a)
      return "On maintenance dialysis — monitor adequacy and access." if a.on_dialysis

      parts = []
      parts << "Latest eGFR #{a.latest_egfr.round(0)} mL/min" if a.latest_egfr
      if a.slope_per_year
        dir = a.slope_per_year.negative? ? "declining" : "stable/improving"
        parts << "#{dir} #{a.slope_per_year.abs} mL/min per year"
      end
      if a.projected_months_to_esrd && a.projected_months_to_esrd.positive?
        parts << "projected to reach ESRD threshold in ~#{a.projected_months_to_esrd} months at current rate"
      end
      parts.any? ? parts.join(" · ").upcase_first : "Insufficient lab history for a trend — order a renal panel."
    end
  end
end
