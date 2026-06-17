module Admin
  class QualityController < Admin::BaseController
    def index
      @data = Quality::ReportBuilder.call
    end

    def export
      data = Quality::ReportBuilder.call
      pdf = Quality::PdfReport.call(data, hospital: current_hospital)
      send_data pdf,
        filename: "quality-report-#{Date.current.iso8601}.pdf",
        type: "application/pdf",
        disposition: "attachment"
    end
  end
end
