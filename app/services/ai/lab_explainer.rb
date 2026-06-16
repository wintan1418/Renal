module Ai
  # Patient-facing plain-language explanation of a set of lab results.
  # Reassuring, accurate, non-alarmist — and never a substitute for the doctor.
  class LabExplainer < Base
    # results: array of LabResult (with lab_test loaded)
    def initialize(results)
      @results = Array(results)
    end

    private

    def temperature = 0.3

    def system_prompt
      <<~SYS
        You explain kidney-related lab results to patients in simple, warm,
        plain English (Nigerian context). Be accurate and reassuring without
        minimising real concerns. Avoid medical jargon; when you must use a term,
        explain it. Do NOT diagnose or recommend medication changes — always
        direct the patient to discuss specifics with their nephrologist. 2–4 short
        paragraphs.
      SYS
    end

    def user_prompt
      lines = @results.map do |r|
        t = r.lab_test
        range = [ t&.normal_range_min, t&.normal_range_max ].compact.join("–")
        "#{t&.name || 'Test'}: #{r.value} #{t&.unit} (normal #{range.presence || 'n/a'}) — flag: #{r.flag}"
      end
      "Explain these results for the patient:\n#{lines.join("\n")}"
    end

    def fallback
      @results.map do |r|
        t = r.lab_test
        status = case r.flag.to_s
                 when "normal" then "is within the normal range"
                 when "low" then "is a little below the usual range"
                 when "high" then "is a little above the usual range"
                 else "needs review by your doctor"
        end
        "Your #{t&.name || 'result'} (#{r.value} #{t&.unit}) #{status}."
      end.join(" ") + " Please discuss these with your nephrologist at your next visit."
    end
  end
end
