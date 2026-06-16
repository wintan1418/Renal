module Staff
  # JSON endpoints backing the in-form AI helpers (e.g. the SOAP scribe).
  class AiController < Staff::BaseController
    # POST /staff/ai/scribe
    # Turns rough free-text notes into structured SOAP sections.
    def scribe
      notes = params[:notes].to_s.strip
      return render(json: { error: "No notes provided" }, status: :unprocessable_entity) if notes.blank?

      result = Ai::ClinicalScribe.call(notes, context: scribe_context)
      render json: parse_soap(result.content).merge(source: result.ai? ? "AI · #{result.source}" : "rule-based")
    end

    private

    def scribe_context
      ctx = {}
      ctx[:patient] = params[:patient_name] if params[:patient_name].present?
      ctx[:reason] = params[:reason] if params[:reason].present?
      ctx
    end

    # The scribe prompt enforces "Subjective:/Objective:/Assessment:/Plan:"
    # headings, so we split on them. Anything before the first heading (or the
    # whole text if none) becomes Subjective.
    def parse_soap(text)
      sections = { subjective: "", objective: "", assessment: "", plan: "" }
      current = :subjective
      headings = {
        /\Asubjective:/i => :subjective, /\Aobjective:/i => :objective,
        /\Aassessment:/i => :assessment, /\Aplan:/i => :plan
      }

      text.to_s.each_line do |raw|
        # Strip markdown noise (** bold, # headings, leading bullets) before matching.
        line = raw.gsub("**", "").gsub(/\A\s*#+\s*/, "").gsub(/\A\s*[-*]\s+/, "")
        stripped = line.strip

        if (match = headings.find { |re, _| stripped.match?(re) })
          current = match.last
          rest = stripped.sub(/\A[a-z]+:/i, "").strip
          sections[current] << "#{rest}\n" unless rest.empty?
        else
          sections[current] << line.gsub("**", "")
        end
      end

      sections.transform_values(&:strip)
    end
  end
end
