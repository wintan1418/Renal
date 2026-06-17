module Intelligence
  # A compact, factual snapshot of the practice that the AI analyst answers
  # questions from. Keeps numbers in one place so answers are grounded.
  class PracticeSnapshot < ApplicationService
    def call
      today = Date.current
      adequacy = DialysisSession.where.not(kt_v: nil)
      {
        generated_on: today.to_s,
        patients_total: User.where(role: :patient).count,
        patients_on_dialysis: PatientProfile.where(on_dialysis: true).count,
        ckd_stage_distribution: PatientProfile.where.not(ckd_stage: nil).group(:ckd_stage).count
                                  .transform_keys { |k| PatientProfile.ckd_stages.key(k)&.humanize || k.to_s },
        doctors: User.doctors.active.count,
        appointments_today: Appointment.where(scheduled_date: today).count,
        appointments_this_week: Appointment.where(scheduled_date: today.beginning_of_week..today.end_of_week).count,
        no_show_rate_30d: no_show_rate(today),
        dialysis_sessions_this_week: DialysisSession.where(session_date: today.beginning_of_week..today.end_of_week).count,
        dialysis_avg_kt_v: adequacy.average(:kt_v)&.round(2),
        dialysis_avg_urr: adequacy.average(:urr)&.round(1),
        dialysis_pct_adequate: pct_adequate(adequacy),
        revenue: Billing::RevenueReport.call[:kpis].slice(:invoiced_cents, :collected_cents, :outstanding_cents, :collection_rate),
        consumables_to_reorder: DialysisConsumable.where("quantity_in_stock <= reorder_level").pluck(:name),
        open_leads: ContactSubmission.open_pipeline.count
      }
    end

    private

    def no_show_rate(today)
      scope = Appointment.where(scheduled_date: (today - 30.days)..today, status: %i[completed no_show])
      total = scope.count
      return 0 if total.zero?
      ((scope.where(status: :no_show).count.to_f / total) * 100).round(1)
    end

    def pct_adequate(scope)
      n = scope.count
      return nil if n.zero?
      ok = scope.where("kt_v >= 1.2 OR urr >= 65").count
      ((ok.to_f / n) * 100).round
    end
  end
end
