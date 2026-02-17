module Dialysis
  class AssignResourcesService < ApplicationService
    def initialize(session:, machine_id: nil, station_id: nil)
      @session = session
      @machine_id = machine_id
      @station_id = station_id
    end

    def call
      machine = DialysisMachine.find_by(id: @machine_id) if @machine_id.present?
      station = DialysisStation.find_by(id: @station_id) if @station_id.present?

      if machine && !machine.status_available?
        return Result.new(success?: false, error: "Machine #{machine.name} is not available (#{machine.status})")
      end

      if station && !station.status_available?
        return Result.new(success?: false, error: "Station #{station.name} is not available (#{station.status})")
      end

      @session.update!(dialysis_machine: machine, dialysis_station: station)
      Result.new(success?: true, data: @session)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success?: false, error: e.message)
    end
  end
end
