class Admin::VisitsController < Admin::BaseController
  def index
    visits = Visit.includes(:patient, :doctor, :appointment)
    visits = visits.where(status: params[:status]) if params[:status].present?
    visits = visits.where(visit_date: params[:date]) if params[:date].present?
    @pagy, @visits = pagy(visits.order(visit_date: :desc, created_at: :desc), items: 20)
  end

  def show
    @visit = Visit.includes(:patient, :doctor, :clinical_notes, :vital_signs, :diagnoses, :lab_orders, :prescriptions).find(params[:id])
  end
end
