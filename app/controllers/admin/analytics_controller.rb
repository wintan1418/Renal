class Admin::AnalyticsController < Admin::BaseController
  def index
    result = Analytics::DashboardService.call
    @data = result.data
  end
end
