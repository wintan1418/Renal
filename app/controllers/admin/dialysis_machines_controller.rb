class Admin::DialysisMachinesController < Admin::BaseController
  before_action :set_machine, only: [:show, :edit, :update, :destroy]

  def index
    @machines = DialysisMachine.order(:name)
    @pagy, @machines = pagy(@machines)
  end

  def show; end

  def new
    @machine = DialysisMachine.new
  end

  def create
    @machine = DialysisMachine.new(machine_params)
    if @machine.save
      redirect_to admin_dialysis_machines_path, notice: "Machine created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @machine.update(machine_params)
      redirect_to admin_dialysis_machines_path, notice: "Machine updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @machine.destroy
    redirect_to admin_dialysis_machines_path, notice: "Machine removed."
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to admin_dialysis_machines_path, alert: "Cannot delete machine with associated sessions."
  end

  private

  def set_machine
    @machine = DialysisMachine.find(params[:id])
  end

  def machine_params
    params.require(:dialysis_machine).permit(:name, :serial_number, :model, :manufacturer,
                                              :status, :last_serviced_on, :next_service_due, :notes)
  end
end
