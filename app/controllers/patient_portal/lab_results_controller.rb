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
    @has_results = @lab_order.lab_results.any? { |r| r.value.present? }
    # Explanation loads lazily via a Turbo frame (see #explanation).
  end

  # Lazy-loaded Turbo frame: plain-language explanation of the results.
  def explanation
    @lab_order = current_user.lab_orders_as_patient.includes(lab_results: :lab_test).find(params[:id])
    results = @lab_order.lab_results.select { |r| r.value.present? }
    @explanation = if results.any?
      resilient_cache("ai/lab_explain/#{@lab_order.id}/#{@lab_order.updated_at.to_i}", expires_in: 30.days) do
        Ai::LabExplainer.call(results).content
      end
    end
    render :explanation, layout: false
  end
end
