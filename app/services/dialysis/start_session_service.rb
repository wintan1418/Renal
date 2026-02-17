module Dialysis
  class StartSessionService < ApplicationService
    def initialize(session:, nurse: nil)
      @session = session
      @nurse = nurse
    end

    def call
      unless @session.status_scheduled?
        return Result.new(success?: false, error: "Session cannot be started — current status: #{@session.status}")
      end

      ActiveRecord::Base.transaction do
        @session.update!(
          status: :in_progress,
          start_time: Time.current,
          nurse: @nurse || @session.nurse
        )
        @session.dialysis_station&.update!(status: :occupied)
        @session.dialysis_machine&.update!(status: :in_use)
      end

      Result.new(success?: true, data: @session)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success?: false, error: e.message)
    end
  end
end
