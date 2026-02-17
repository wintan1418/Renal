class Admin::LabTestsController < Admin::BaseController
  def index
    lab_tests = LabTest.all
    lab_tests = lab_tests.where(category: params[:category]) if params[:category].present?
    lab_tests = lab_tests.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    @pagy, @lab_tests = pagy(lab_tests.order(:category, :name), items: 20)
  end

  def new
    @lab_test = LabTest.new
  end

  def create
    @lab_test = LabTest.new(lab_test_params)
    if @lab_test.save
      redirect_to admin_lab_tests_path, notice: "Lab test created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @lab_test = LabTest.find(params[:id])
  end

  def update
    @lab_test = LabTest.find(params[:id])
    if @lab_test.update(lab_test_params)
      redirect_to admin_lab_tests_path, notice: "Lab test updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lab_test = LabTest.find(params[:id])
    if @lab_test.lab_results.any?
      redirect_to admin_lab_tests_path, alert: "Cannot delete lab test with existing results."
    else
      @lab_test.destroy
      redirect_to admin_lab_tests_path, notice: "Lab test deleted."
    end
  end

  private

  def lab_test_params
    params.require(:lab_test).permit(:name, :code, :category, :unit, :normal_range_min, :normal_range_max, :price_cents, :description, :active)
  end
end
