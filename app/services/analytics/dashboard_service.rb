module Analytics
  class DashboardService < ApplicationService
    def call
      Result.new(
        success?: true,
        data: {
          # Patient metrics
          total_patients: User.patient.count,
          new_patients_this_month: User.patient.where(created_at: Time.current.all_month).count,
          active_patients: User.patient.joins(:patient_profile).where(patient_profiles: { on_dialysis: true }).count,

          # Appointment metrics
          appointments_today: Appointment.where(scheduled_date: Date.current).count,
          appointments_this_month: Appointment.where(scheduled_date: Time.current.all_month).count,
          appointment_completion_rate: appointment_completion_rate,

          # Dialysis metrics
          dialysis_sessions_this_month: DialysisSession.where(session_date: Time.current.all_month).count,
          active_sessions: DialysisSession.where(status: :in_progress).count,
          machines_available: DialysisMachine.where(status: :available).count,
          machines_total: DialysisMachine.count,

          # Financial metrics
          revenue_this_month: Invoice.where(status: :paid, created_at: Time.current.all_month).sum(:total_cents),
          outstanding_invoices: Invoice.where(status: [:sent, :overdue]).count,
          outstanding_amount: Invoice.where(status: [:sent, :overdue]).sum(:total_cents) - Invoice.where(status: [:sent, :overdue]).sum(:amount_paid_cents),

          # Clinical metrics
          visits_this_month: Visit.where(visit_date: Time.current.all_month).count,
          pending_lab_orders: LabOrder.where(status: :pending).count,
          transplant_waitlist: TransplantWaitlistEntry.where(status: :active).count,

          # Trend data for charts
          patient_growth: patient_growth_data,
          revenue_trend: revenue_trend_data,
          dialysis_trend: dialysis_trend_data,
          appointment_trend: appointment_trend_data,
          ckd_stage_distribution: ckd_stage_distribution,
        },
        error: nil
      )
    end

    private

    def appointment_completion_rate
      total = Appointment.where(created_at: 30.days.ago..).count
      return 0 if total.zero?
      completed = Appointment.where(status: :completed, created_at: 30.days.ago..).count
      ((completed.to_f / total) * 100).round(1)
    end

    def patient_growth_data
      6.downto(0).map do |months_ago|
        period = months_ago.months.ago
        { period.strftime("%b %Y") => User.patient.where(created_at: period.all_month).count }
      end.reduce(:merge)
    end

    def revenue_trend_data
      6.downto(0).map do |months_ago|
        period = months_ago.months.ago
        { period.strftime("%b %Y") => (Invoice.where(status: :paid, created_at: period.all_month).sum(:total_cents) / 100.0).round(2) }
      end.reduce(:merge)
    end

    def dialysis_trend_data
      6.downto(0).map do |months_ago|
        period = months_ago.months.ago
        { period.strftime("%b %Y") => DialysisSession.where(session_date: period.all_month).count }
      end.reduce(:merge)
    end

    def appointment_trend_data
      7.downto(0).map do |days_ago|
        date = days_ago.days.ago.to_date
        { date.strftime("%a %d") => Appointment.where(scheduled_date: date).count }
      end.reduce(:merge)
    end

    def ckd_stage_distribution
      PatientProfile.group(:ckd_stage).count.transform_keys { |k| "Stage #{k}" }
    end
  end
end
