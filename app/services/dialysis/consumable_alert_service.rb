module Dialysis
  class ConsumableAlertService < ApplicationService
    def initialize
    end

    def call
      low_stock_items = DialysisConsumable.active.low_stock

      return Result.new(success?: true, data: { alerts: 0, items: [] }) if low_stock_items.empty?

      alert_data = low_stock_items.map do |item|
        {
          id: item.id,
          name: item.name,
          category: item.category,
          quantity_in_stock: item.quantity_in_stock,
          reorder_level: item.reorder_level,
          unit: item.unit
        }
      end

      Result.new(success?: true, data: { alerts: low_stock_items.count, items: alert_data })
    end
  end
end
