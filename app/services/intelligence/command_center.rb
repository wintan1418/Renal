module Intelligence
  # Aggregates the whole-practice "smart" view: population health, at-risk
  # patients, revenue intelligence and inventory forecasting. Runs entirely on
  # existing data — no external service or API key required.
  class CommandCenter < ApplicationService
    def call
      {
        population: population_health,
        at_risk: at_risk_patients,
        revenue: revenue_insights,
        inventory: inventory_forecast,
        operations: operations,
        no_show_risks: Intelligence::NoShowPredictor.call(limit: 8)
      }
    end

    private

    def patients
      @patients ||= User.where(role: :patient)
    end

    def population_health
      profiles = PatientProfile.all
      stage_counts = profiles.where.not(ckd_stage: nil).group(:ckd_stage).count
      {
        total_patients: patients.count,
        on_dialysis: profiles.where(on_dialysis: true).count,
        ckd_stage_distribution: stage_counts.transform_keys { |k| PatientProfile.ckd_stages.key(k)&.humanize || k.to_s },
        overdue_labs: overdue_lab_count,
        transplant_waitlisted: TransplantWaitlistEntry.where(status: :active).count
      }
    end

    # Patients whose most recent renal panel is older than 90 days.
    def overdue_lab_count
      cutoff = 90.days.ago.to_date
      with_recent = LabResult.where("result_date >= ?", cutoff).distinct.pluck(:patient_id)
      patients.where.not(id: with_recent).count
    end

    # Score every patient and surface the highest-risk ones for the dashboard.
    def at_risk_patients(limit: 12)
      ranked = patients.includes(:patient_profile).filter_map do |p|
        a = Intelligence::CkdRiskAnalyzer.call(p)
        weight = RISK_WEIGHT[a.risk_level] || 0
        next if weight.zero?

        { patient: p, analysis: a, weight: weight }
      end
      ranked.sort_by { |r| [ -r[:weight], r[:analysis].slope_per_year || 0 ] }.first(limit)
    end

    RISK_WEIGHT = { critical: 4, elevated: 3, monitor: 2, stable: 0, unknown: 0 }.freeze

    def revenue_insights
      paid = Payment.where(status: :successful).sum(:amount_cents)
      invoiced = Invoice.where.not(status: :draft).sum(:total_cents)
      outstanding = Invoice.where.not(status: [ :draft, :paid, :cancelled ]).sum("total_cents - amount_paid_cents")
      monthly = Payment.where(status: :successful)
                       .where("payments.created_at >= ?", 6.months.ago.beginning_of_month)
                       .group_by_month("payments.created_at", format: "%b %Y").sum(:amount_cents)
      {
        collected_cents: paid,
        invoiced_cents: invoiced,
        outstanding_cents: outstanding,
        collection_rate: invoiced.positive? ? ((paid.to_f / invoiced) * 100).round : 0,
        monthly_revenue: monthly.transform_values { |c| (c / 100.0).round }
      }
    end

    # Forecast days-to-stockout from average daily consumption of each item.
    def inventory_forecast
      window_days = 60.0
      DialysisConsumable.where(active: true).map do |item|
        used = DialysisConsumableUsage
                 .where(dialysis_consumable_id: item.id)
                 .where("created_at >= ?", window_days.days.ago)
                 .sum(:quantity_used)
        per_day = used / window_days
        days_left = per_day.positive? ? (item.quantity_in_stock / per_day).round : nil
        {
          name: item.name,
          in_stock: item.quantity_in_stock,
          reorder_level: item.reorder_level,
          per_day: per_day.round(2),
          days_to_stockout: days_left,
          status: stock_status(item, days_left)
        }
      end.sort_by { |i| i[:days_to_stockout] || Float::INFINITY }
    end

    def stock_status(item, days_left)
      return :reorder_now if item.quantity_in_stock <= item.reorder_level
      return :reorder_soon if days_left && days_left <= 21
      :ok
    end

    def operations
      today = Date.current
      {
        sessions_today: DialysisSession.where(session_date: today).count,
        sessions_this_week: DialysisSession.where(session_date: today.beginning_of_week..today.end_of_week).count,
        stations_available: DialysisStation.where(status: :available).count,
        stations_total: DialysisStation.count,
        machines_operational: DialysisMachine.where(status: :available).count,
        upcoming_appointments: Appointment.where(scheduled_date: today..(today + 7.days)).where.not(status: :cancelled).count
      }
    end
  end
end
