class Admin::DialysisConsumablesController < Admin::BaseController
  before_action :set_consumable, only: [:edit, :update, :destroy]

  def index
    @consumables = DialysisConsumable.order(:name)
    @consumables = @consumables.where(category: params[:category]) if params[:category].present?
    @low_stock_count = DialysisConsumable.active.low_stock.count
    @pagy, @consumables = pagy(@consumables)
  end

  def new
    @consumable = DialysisConsumable.new
  end

  def create
    @consumable = DialysisConsumable.new(consumable_params)
    if @consumable.save
      redirect_to admin_dialysis_consumables_path, notice: "Consumable added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @consumable.update(consumable_params)
      redirect_to admin_dialysis_consumables_path, notice: "Consumable updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @consumable.destroy
    redirect_to admin_dialysis_consumables_path, notice: "Consumable removed."
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to admin_dialysis_consumables_path, alert: "Cannot delete consumable with usage records."
  end

  private

  def set_consumable
    @consumable = DialysisConsumable.find(params[:id])
  end

  def consumable_params
    params.require(:dialysis_consumable).permit(:name, :category, :unit, :quantity_in_stock,
                                                 :reorder_level, :unit_cost_cents, :supplier,
                                                 :description, :active)
  end
end
