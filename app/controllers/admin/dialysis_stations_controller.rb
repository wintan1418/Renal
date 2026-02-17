class Admin::DialysisStationsController < Admin::BaseController
  before_action :set_station, only: [:edit, :update, :destroy]

  def index
    @stations = DialysisStation.order(:name)
    @pagy, @stations = pagy(@stations)
  end

  def new
    @station = DialysisStation.new
  end

  def create
    @station = DialysisStation.new(station_params)
    if @station.save
      redirect_to admin_dialysis_stations_path, notice: "Station created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @station.update(station_params)
      redirect_to admin_dialysis_stations_path, notice: "Station updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @station.destroy
    redirect_to admin_dialysis_stations_path, notice: "Station removed."
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to admin_dialysis_stations_path, alert: "Cannot delete station with associated sessions."
  end

  private

  def set_station
    @station = DialysisStation.find(params[:id])
  end

  def station_params
    params.require(:dialysis_station).permit(:name, :station_type, :status, :notes)
  end
end
