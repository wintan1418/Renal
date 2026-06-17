module Quality
  # Practice-level quality & compliance metrics (renal-focused). Used by the
  # quality dashboard and the PDF export.
  class ReportBuilder < ApplicationService
    def call
      {
        generated_at: Time.current,
        dialysis: dialysis_quality,
        appointments: appointment_quality,
        labs: lab_quality,
        access: access_quality,
        population: population
      }
    end

    private

    def dialysis_quality
      measured = DialysisSession.where.not(kt_v: nil)
      total = measured.count
      adequate = measured.where("kt_v >= 1.2 OR urr >= 65").count
      {
        measured_sessions: total,
        pct_adequate: total.zero? ? nil : ((adequate.to_f / total) * 100).round,
        mean_kt_v: measured.average(:kt_v)&.round(2),
        mean_urr: measured.average(:urr)&.round(1),
        sessions_total: DialysisSession.count
      }
    end

    def appointment_quality
      scope = Appointment.where(scheduled_date: 90.days.ago.to_date..Date.current)
      total = scope.count
      completed = scope.where(status: :completed).count
      no_show = scope.where(status: :no_show).count
      decided = completed + no_show
      {
        total_90d: total,
        completion_rate: total.zero? ? nil : ((completed.to_f / total) * 100).round,
        no_show_rate: decided.zero? ? nil : ((no_show.to_f / decided) * 100).round(1),
        cancelled: scope.where(status: :cancelled).count
      }
    end

    def lab_quality
      scope = LabResult.where(result_date: 90.days.ago.to_date..Date.current)
      {
        results_90d: scope.count,
        abnormal: scope.where(flag: [ :low, :high ]).count,
        critical: scope.where(flag: :critical).count
      }
    end

    def access_quality
      total = VascularAccess.count
      {
        total: total,
        pct_functioning: total.zero? ? nil : ((VascularAccess.status_functioning.count.to_f / total) * 100).round,
        infected: VascularAccess.status_infected.count
      }
    end

    def population
      {
        patients: User.where(role: :patient).count,
        on_dialysis: PatientProfile.where(on_dialysis: true).count,
        transplant_waitlist: TransplantWaitlistEntry.where(status: :active).count,
        ckd_stages: PatientProfile.where.not(ckd_stage: nil).group(:ckd_stage).count
                      .transform_keys { |k| PatientProfile.ckd_stages.key(k)&.humanize || k.to_s }
      }
    end
  end
end
