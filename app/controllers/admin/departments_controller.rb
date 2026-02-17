class Admin::DepartmentsController < Admin::BaseController
  before_action :set_department, only: [ :show, :edit, :update, :destroy ]

  def index
    departments = Department.all
    departments = departments.where("name ILIKE :q OR description ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
    @pagy, @departments = pagy(departments.order(:name), items: 20)
  end

  def show
  end

  def new
    @department = Department.new
  end

  def create
    @department = Department.new(department_params)
    if @department.save
      redirect_to admin_departments_path, notice: "Department created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @department.update(department_params)
      redirect_to admin_departments_path, notice: "Department updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @department.update(active: false)
    redirect_to admin_departments_path, notice: "Department deactivated."
  end

  private

  def set_department
    @department = Department.find(params[:id])
  end

  def department_params
    params.require(:department).permit(:name, :description, :head_of_department_id, :active)
  end
end
