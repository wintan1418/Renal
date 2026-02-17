class PatientPortal::LabResultsController < PatientPortal::BaseController
  def index
    lab_orders = current_user.lab_orders_as_patient
      .includes(:ordered_by, lab_results: :lab_test)
      .order(created_at: :desc)
    @pagy, @lab_orders = pagy(lab_orders, items: 10)
  end

  def show
    @lab_order = current_user.lab_orders_as_patient
      .includes(lab_results: :lab_test)
      .find(params[:id])

    # For trend chart data - get recent results for each test in this order
    @trend_data = {}
    @lab_order.lab_results.each do |result|
      history = LabResult.where(patient: current_user, lab_test: result.lab_test)
        .where.not(numeric_value: nil)
        .order(result_date: :asc)
        .last(10)
      if history.length > 1
        @trend_data[result.lab_test.name] = history.map { |r| [ r.result_date&.to_s || r.created_at.to_date.to_s, r.numeric_value.to_f ] }
      end
    end
  end
end
