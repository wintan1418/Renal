module Ai
  # Answers natural-language questions about the practice, grounded strictly in
  # a provided metrics snapshot (no database access — avoids hallucinated SQL).
  class DataAnalyst < Base
    def initialize(question, snapshot: nil)
      @question = question.to_s.strip
      @snapshot = snapshot || Intelligence::PracticeSnapshot.call
    end

    private

    def temperature = 0.2

    def system_prompt
      <<~SYS
        You are a data analyst for a renal hospital management system. Answer the
        user's question using ONLY the JSON metrics snapshot provided — do not
        invent numbers. If the snapshot doesn't contain the answer, say so plainly
        and suggest what's available. Money values are in minor units (cents):
        divide by 100 for the displayed amount. Be concise and direct; use short
        bullet points or a one-line answer where possible.
      SYS
    end

    def user_prompt
      <<~PROMPT
        METRICS SNAPSHOT (JSON):
        #{@snapshot.to_json}

        QUESTION: #{@question}
      PROMPT
    end

    def fallback
      r = @snapshot[:revenue] || {}
      "AI isn't configured, but here's the current snapshot: " \
      "#{@snapshot[:patients_total]} patients (#{@snapshot[:patients_on_dialysis]} on dialysis), " \
      "#{@snapshot[:appointments_today]} appointments today, " \
      "collection rate #{r[:collection_rate]}%, " \
      "avg Kt/V #{@snapshot[:dialysis_avg_kt_v] || 'n/a'}. " \
      "Set an AI provider key to ask free-form questions."
    end
  end
end
