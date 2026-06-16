module Staff
  # JSON endpoints backing the in-form AI helpers (e.g. the SOAP scribe).
  class AiController < Staff::BaseController
    # POST /staff/ai/scribe
    # Turns rough free-text notes into structured SOAP sections.
    def scribe
      notes = params[:notes].to_s.strip
      return render(json: { error: "No notes provided" }, status: :unprocessable_entity) if notes.blank?

      data = Ai::ClinicalScribe.soap(notes, context: scribe_context)
      render json: data.slice(:subjective, :objective, :assessment, :plan)
                       .merge(source: data[:ai] ? "AI · #{data[:source]}" : "rule-based")
    end

    private

    def scribe_context
      ctx = {}
      ctx[:patient] = params[:patient_name] if params[:patient_name].present?
      ctx[:reason] = params[:reason] if params[:reason].present?
      ctx
    end
  end
end
