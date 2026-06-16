class PatientPortal::DashboardController < PatientPortal::BaseController
  def index
    @upcoming_appointments = current_user.appointments_as_patient
                                         .active_statuses
                                         .where("scheduled_date >= ?", Date.current)
                                         .includes(:doctor, :service, :department)
                                         .order(:scheduled_date, :start_time)
                                         .limit(5)
    @next_appointment = @upcoming_appointments.first

    @recent_lab_results = current_user.lab_results
                                      .includes(:lab_test)
                                      .recent
                                      .limit(5)

    @active_prescriptions = current_user.prescriptions_as_patient.active_prescriptions

    @unpaid_invoices = current_user.invoices_as_patient.unpaid
    @outstanding_cents = @unpaid_invoices.sum { |i| i.balance_due_cents }

    @stats = {
      upcoming: @upcoming_appointments.size,
      pending_labs: @recent_lab_results.size,
      active_prescriptions: @active_prescriptions.size,
      outstanding_cents: @outstanding_cents
    }
  end
end
