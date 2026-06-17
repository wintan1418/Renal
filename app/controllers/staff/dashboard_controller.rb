class Staff::DashboardController < Staff::BaseController
  def index
    @doctor = current_user
    today = Date.current

    @today_appointments = @doctor.appointments_as_doctor
      .where(scheduled_date: today)
      .includes(:patient, :service)
      .order(:start_time)

    @stats = {
      today: @today_appointments.size,
      seen_today: @doctor.appointments_as_doctor.where(scheduled_date: today, status: :completed).count,
      pending_labs: @doctor.lab_orders_ordered.pending_orders.count,
      dialysis_today: @doctor.dialysis_sessions_as_doctor.where(session_date: today).count
    }

    @upcoming = @doctor.appointments_as_doctor
      .where("scheduled_date > ?", today)
      .where(status: [ :pending, :confirmed ])
      .includes(:patient)
      .order(:scheduled_date, :start_time)
      .limit(5)

    @recent_visits = @doctor.visits_as_doctor
      .includes(:patient)
      .order(visit_date: :desc)
      .limit(6)

    @lab_review = @doctor.lab_orders_ordered.status_completed
      .includes(:patient, lab_results: :lab_test)
      .order(completed_at: :desc)
      .limit(5)

    # Patients with recent abnormal results — surfaced for review.
    patient_ids = @doctor.appointments_as_doctor.distinct.pluck(:patient_id)
    @attention = LabResult.where(patient_id: patient_ids, flag: [ :high, :critical ])
      .where.not(numeric_value: nil)
      .includes(:patient, :lab_test)
      .order(result_date: :desc)
      .to_a.uniq(&:patient_id).first(5)

    # Weekly appointment volume (last 7 days) for a simple bar strip.
    week = (0..6).map { |i| today - (6 - i).days }
    counts = @doctor.appointments_as_doctor.where(scheduled_date: week.first..week.last).group(:scheduled_date).count
    @week_volume = week.map { |d| [ d, counts[d] || 0 ] }
  end
end
