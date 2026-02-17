module Dialysis
  class CompleteSessionService < ApplicationService
    def initialize(session:, params:)
      @session = session
      @params = params
    end

    def call
      return Result.new(success?: false, error: "Session is not in progress") unless @session.status_in_progress?

      ActiveRecord::Base.transaction do
        fluid_removed = if @params[:pre_weight_kg].present? && @params[:post_weight_kg].present?
          ((@params[:pre_weight_kg].to_f - @params[:post_weight_kg].to_f) * 1000).round(0)
        else
          @params[:fluid_removed_ml]
        end

        duration = if @session.start_time.present?
          ((Time.current - @session.start_time) / 60).round
        end

        @session.update!(
          @params.merge(
            status: :completed,
            end_time: Time.current,
            fluid_removed_ml: fluid_removed || @params[:fluid_removed_ml],
            duration_minutes: duration
          )
        )

        @session.dialysis_station&.update!(status: :cleaning)
        @session.dialysis_machine&.update!(status: :available)
      end

      Result.new(success?: true, data: @session)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success?: false, error: e.message)
    end
  end
end
