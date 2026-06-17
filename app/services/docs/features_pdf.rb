require "prawn"

module Docs
  # Renders the feature catalogue as a PDF (Prawn). Returns the binary string.
  class FeaturesPdf < ApplicationService
    def initialize(hospital: nil)
      @hospital = hospital
    end

    def call
      Prawn::Document.new(page_size: "A4", margin: 44) do |pdf|
        pdf.fill_color "0B2437"
        pdf.text(@hospital&.name.presence || "Healthroom Renal Centre", size: 22, style: :bold)
        pdf.fill_color "2B8B75"
        pdf.text "Platform Feature Overview", size: 13
        pdf.fill_color "888888"
        pdf.text "A complete, AI-powered renal hospital & dialysis management platform.", size: 9
        pdf.stroke_color "DDDDDD"
        pdf.stroke_horizontal_rule
        pdf.move_down 12

        Docs::FeatureCatalog.sections.each do |sec|
          pdf.fill_color "0B2437"
          pdf.text sec[:title], size: 13, style: :bold
          if sec[:blurb].present?
            pdf.fill_color "2B8B75"
            pdf.text sec[:blurb], size: 9, style: :italic
          end
          pdf.fill_color "222222"
          pdf.move_down 3
          sec[:items].each do |item|
            pdf.text "- #{item}", size: 9.5, leading: 2
          end
          pdf.move_down 12
        end

        pdf.fill_color "888888"
        pdf.text "Generated #{Time.current.strftime('%B %d, %Y')}", size: 8
        pdf.number_pages "<page> / <total>", at: [ pdf.bounds.right - 50, -10 ], size: 8, color: "AAAAAA"
      end.render
    end
  end
end
