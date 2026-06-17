require "prawn"
require "prawn/table"

module Quality
  # Renders the quality report as a PDF (Prawn). Returns the binary string.
  class PdfReport < ApplicationService
    def initialize(data, hospital: nil)
      @d = data
      @hospital = hospital
    end

    def call
      Prawn::Document.new(page_size: "A4", margin: 40) do |pdf|
        header(pdf)
        section(pdf, "Dialysis adequacy", dialysis_rows)
        section(pdf, "Appointments (last 90 days)", appointment_rows)
        section(pdf, "Laboratory (last 90 days)", lab_rows)
        section(pdf, "Vascular access", access_rows)
        section(pdf, "Population", population_rows)
        pdf.move_down 18
        pdf.fill_color "888888"
        pdf.text "Generated #{@d[:generated_at].strftime('%B %d, %Y %H:%M')}  -  Decision-support summary, not a regulatory submission.", size: 8
      end.render
    end

    private

    def header(pdf)
      pdf.fill_color "0B2437"
      pdf.text(@hospital&.name.presence || "Healthroom Renal Centre", size: 20, style: :bold)
      pdf.fill_color "2B8B75"
      pdf.text "Quality & Compliance Report", size: 13
      pdf.fill_color "000000"
      pdf.move_down 14
    end

    def section(pdf, title, rows)
      return if rows.blank?
      pdf.move_down 10
      pdf.fill_color "0B2437"
      pdf.text title, size: 12, style: :bold
      pdf.fill_color "000000"
      pdf.move_down 4
      pdf.table(rows, width: pdf.bounds.width, cell_style: { size: 9, padding: [ 5, 8 ], border_color: "DDDDDD" }) do
        column(0).font_style = :bold
        column(0).width = 220
      end
    end

    def pct(v) = v.nil? ? "—" : "#{v}%"

    def dialysis_rows
      d = @d[:dialysis]
      [
        [ "Measured sessions", d[:measured_sessions].to_s ],
        [ "Sessions meeting target", pct(d[:pct_adequate]) ],
        [ "Mean Kt/V (target >=1.2)", (d[:mean_kt_v] || "—").to_s ],
        [ "Mean URR (target >=65%)", d[:mean_urr] ? "#{d[:mean_urr]}%" : "—" ],
        [ "Total sessions on record", d[:sessions_total].to_s ]
      ]
    end

    def appointment_rows
      a = @d[:appointments]
      [
        [ "Appointments (90 days)", a[:total_90d].to_s ],
        [ "Completion rate", pct(a[:completion_rate]) ],
        [ "No-show rate", a[:no_show_rate] ? "#{a[:no_show_rate]}%" : "—" ],
        [ "Cancelled", a[:cancelled].to_s ]
      ]
    end

    def lab_rows
      l = @d[:labs]
      [ [ "Results (90 days)", l[:results_90d].to_s ], [ "Abnormal", l[:abnormal].to_s ], [ "Critical", l[:critical].to_s ] ]
    end

    def access_rows
      a = @d[:access]
      return [] if a[:total].to_i.zero?
      [ [ "Access points", a[:total].to_s ], [ "Functioning", pct(a[:pct_functioning]) ], [ "Infected", a[:infected].to_s ] ]
    end

    def population_rows
      p = @d[:population]
      rows = [ [ "Patients", p[:patients].to_s ], [ "On dialysis", p[:on_dialysis].to_s ], [ "Transplant waitlist", p[:transplant_waitlist].to_s ] ]
      p[:ckd_stages].each { |stage, n| rows << [ "  #{stage}", n.to_s ] }
      rows
    end
  end
end
