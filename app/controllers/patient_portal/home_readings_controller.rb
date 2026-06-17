module PatientPortal
  class HomeReadingsController < PatientPortal::BaseController
    def index
      @reading = current_user.home_readings.new(recorded_on: Date.current)
      @readings = current_user.home_readings.recent.limit(30)
      window = current_user.home_readings.since(30.days.ago.to_date)
      @adherence = HomeReading.adherence_rate(window)
      @avg_systolic = window.where.not(systolic_bp: nil).average(:systolic_bp)&.round
      @avg_diastolic = window.where.not(diastolic_bp: nil).average(:diastolic_bp)&.round
    end

    def create
      @reading = current_user.home_readings.new(reading_params)
      if @reading.save
        redirect_to patient_portal_home_readings_path, notice: "Reading saved. Thank you for checking in!"
      else
        @readings = current_user.home_readings.recent.limit(30)
        @adherence = HomeReading.adherence_rate(current_user.home_readings.since(30.days.ago.to_date))
        flash.now[:alert] = @reading.errors.full_messages.to_sentence
        render :index, status: :unprocessable_entity
      end
    end

    private

    def reading_params
      params.require(:home_reading).permit(:recorded_on, :systolic_bp, :diastolic_bp, :pulse, :weight_kg, :meds_taken, :notes)
    end
  end
end
