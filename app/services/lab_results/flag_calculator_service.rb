module LabResults
  class FlagCalculatorService < ApplicationService
    CRITICAL_THRESHOLD = 0.5 # 50% beyond normal range is critical

    def initialize(lab_result:)
      @lab_result = lab_result
      @lab_test = lab_result.lab_test
    end

    def call
      return Result.new(success?: true, data: :normal) unless @lab_result.numeric_value.present?
      return Result.new(success?: true, data: :normal) unless has_reference_range?

      flag = calculate_flag
      @lab_result.update(flag: flag)
      Result.new(success?: true, data: flag)
    end

    private

    def has_reference_range?
      @lab_test.normal_range_min.present? || @lab_test.normal_range_max.present?
    end

    def calculate_flag
      value = @lab_result.numeric_value

      if @lab_test.normal_range_min && value < @lab_test.normal_range_min
        below_by = @lab_test.normal_range_min - value
        range_span = (@lab_test.normal_range_max || @lab_test.normal_range_min) - @lab_test.normal_range_min
        range_span = @lab_test.normal_range_min if range_span.zero?

        below_by.abs / range_span.abs > CRITICAL_THRESHOLD ? :critical : :low
      elsif @lab_test.normal_range_max && value > @lab_test.normal_range_max
        above_by = value - @lab_test.normal_range_max
        range_span = @lab_test.normal_range_max - (@lab_test.normal_range_min || @lab_test.normal_range_max)
        range_span = @lab_test.normal_range_max if range_span.zero?

        above_by.abs / range_span.abs > CRITICAL_THRESHOLD ? :critical : :high
      else
        :normal
      end
    end
  end
end
