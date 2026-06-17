module Admin
  class RevenueController < Admin::BaseController
    def index
      @data = Billing::RevenueReport.call
    end
  end
end
