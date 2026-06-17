module Public
  class DocumentController < ApplicationController
    layout "public"

    def show
      @sections = Docs::FeatureCatalog.sections
    end

    def download
      pdf = Docs::FeaturesPdf.call(hospital: current_hospital)
      send_data pdf,
        filename: "healthroom-features.pdf",
        type: "application/pdf",
        disposition: "attachment"
    end
  end
end
