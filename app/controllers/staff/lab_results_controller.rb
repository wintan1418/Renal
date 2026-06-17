class Staff::LabResultsController < Staff::BaseController
  def index
    orders = current_user.lab_orders_ordered.includes(:patient, lab_results: :lab_test).recent
    @pending = orders.pending_orders.limit(25)
    @completed = orders.status_completed.limit(25)
  end

  def edit
    @lab_result = LabResult.includes(:lab_test, :lab_order).find(params[:id])
    @patient = @lab_result.patient
  end

  def update
    @lab_result = LabResult.find(params[:id])
    @patient = @lab_result.patient

    if @lab_result.update(lab_result_params.merge(resulted_by: current_user, result_date: Date.current))
      # Auto-calculate flag if service exists
      if defined?(LabResults::FlagCalculatorService)
        LabResults::FlagCalculatorService.call(lab_result: @lab_result)
      else
        # Simple flag calculation based on normal range
        test = @lab_result.lab_test
        if @lab_result.numeric_value.present? && test.normal_range_min.present? && test.normal_range_max.present?
          if @lab_result.numeric_value < test.normal_range_min
            @lab_result.update_column(:flag, :low)
          elsif @lab_result.numeric_value > test.normal_range_max
            @lab_result.update_column(:flag, :high)
          else
            @lab_result.update_column(:flag, :normal)
          end
        end
      end

      # Mark order as completed if all results entered
      order = @lab_result.lab_order
      if order.all_results_entered?
        order.update(status: :completed, completed_at: Time.current)
      end

      redirect_to staff_patient_lab_order_path(@patient, @lab_result.lab_order), notice: "Result saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def lab_result_params
    params.require(:lab_result).permit(:value, :numeric_value, :notes)
  end
end
