class Admin::DashboardController < Admin::BaseController
  def index
    @total_patients = User.patient.count
    @total_doctors = User.doctor.count
    @total_staff = User.staff.count
    @recent_users = User.order(created_at: :desc).limit(10)
    @departments = Department.active
  end
end
