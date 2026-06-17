module Clinical
  # Latest values for the key renal markers (kidney function, anaemia, mineral
  # & bone disorder) with renal target ranges — a one-glance renal snapshot.
  class RenalLabPanel < ApplicationService
    MARKERS = [
      { code: "EGFR",  label: "eGFR",         unit: "mL/min", min: 60,  max: nil, group: "Function" },
      { code: "CREAT", label: "Creatinine",   unit: "mg/dL",  min: 0.6, max: 1.2, group: "Function" },
      { code: "HGB",   label: "Haemoglobin",  unit: "g/dL",   min: 10,  max: 12,  group: "Anaemia" },
      { code: "FER",   label: "Ferritin",     unit: "ng/mL",  min: 100, max: 500, group: "Anaemia" },
      { code: "CA",    label: "Calcium",      unit: "mg/dL",  min: 8.4, max: 10.2, group: "Bone & mineral" },
      { code: "PHOS",  label: "Phosphorus",   unit: "mg/dL",  min: 3.5, max: 5.5, group: "Bone & mineral" },
      { code: "PTH",   label: "PTH",          unit: "pg/mL",  min: 150, max: 300, group: "Bone & mineral" },
      { code: "K",     label: "Potassium",    unit: "mEq/L",  min: 3.5, max: 5.0, group: "Electrolytes" }
    ].freeze

    def initialize(patient)
      @patient = patient
    end

    def call
      latest = LabResult.joins(:lab_test)
                        .where(patient_id: @patient.id, lab_tests: { code: MARKERS.map { |m| m[:code] } })
                        .where.not(numeric_value: nil)
                        .order(:result_date)
                        .group_by { |r| r.lab_test.code }

      MARKERS.filter_map do |m|
        result = latest[m[:code]]&.last
        next unless result
        value = result.numeric_value.to_f
        {
          label: m[:label], unit: m[:unit], group: m[:group],
          value: value, target: target_text(m),
          status: status_for(value, m), date: result.result_date
        }
      end
    end

    private

    def target_text(m)
      return "≥ #{m[:min]}" if m[:max].nil?
      "#{m[:min]}–#{m[:max]}"
    end

    def status_for(value, m)
      return :low if m[:min] && value < m[:min]
      return :high if m[:max] && value > m[:max]
      :normal
    end
  end
end
