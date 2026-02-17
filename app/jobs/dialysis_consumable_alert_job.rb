class DialysisConsumableAlertJob < ApplicationJob
  queue_as :default

  def perform
    Dialysis::ConsumableAlertService.call
  end
end
