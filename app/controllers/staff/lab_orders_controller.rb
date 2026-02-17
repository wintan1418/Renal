class Staff::LabOrdersController < Staff::BaseController
  before_action :set_patient

  def new
    @lab_order = LabOrder.new(patient: @patient, ordered_by: current_user)
    @lab_tests = LabTest.active_tests.order(:category, :name)
    @visit = Visit.find(params[:visit_id]) if params[:visit_id]
  end

  def create
    @lab_order = LabOrder.new(lab_order_params.merge(patient: @patient, ordered_by: current_user))

    if @lab_order.save
      # Create lab_result placeholders for selected tests
      if params[:lab_test_ids].present?
        params[:lab_test_ids].each do |test_id|
          @lab_order.lab_results.create!(lab_test_id: test_id, patient: @patient)
        end
      end

      if @lab_order.visit
        redirect_to staff_patient_visit_path(@patient, @lab_order.visit), notice: "Lab order created."
      else
        redirect_to chart_staff_patient_path(@patient, tab: "labs"), notice: "Lab order created."
      end
    else
      @lab_tests = LabTest.active_tests.order(:category, :name)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @lab_order = @patient.lab_orders_as_patient.includes(lab_results: :lab_test).find(params[:id])
  end

  def update
    @lab_order = @patient.lab_orders_as_patient.find(params[:id])
    if @lab_order.update(lab_order_params)
      redirect_to staff_patient_lab_order_path(@patient, @lab_order), notice: "Lab order updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_patient
    @patient = User.find(params[:patient_id])
  end

  def lab_order_params
    params.require(:lab_order).permit(:visit_id, :priority, :clinical_notes, :status)
  end
end
