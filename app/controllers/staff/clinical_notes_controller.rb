module Staff
  class ClinicalNotesController < Staff::BaseController
    def create
      @patient = User.where(role: :patient).find(params[:patient_id])
      @visit = @patient.visits_as_patient.find(params[:visit_id])
      @note = @visit.clinical_notes.new(clinical_note_params)
      @note.author = current_user

      # If the doctor only typed rough notes (no SOAP fields filled), structure
      # them server-side — uses AI when available, otherwise the raw text lands
      # in Subjective. Guarantees a save instead of a silent validation failure.
      apply_raw_notes if @note.soap? && soap_blank? && params[:raw_notes].present?

      if @note.save
        redirect_to staff_patient_visit_path(@patient, @visit), notice: "Clinical note added."
      else
        redirect_to staff_patient_visit_path(@patient, @visit), alert: @note.errors.full_messages.to_sentence
      end
    end

    private

    def soap_blank?
      [ @note.subjective, @note.objective, @note.assessment, @note.plan ].all?(&:blank?)
    end

    def apply_raw_notes
      soap = Ai::ClinicalScribe.soap(params[:raw_notes], context: { patient: @patient.full_name, reason: @visit.chief_complaint })
      @note.subjective = soap[:subjective]
      @note.objective  = soap[:objective]
      @note.assessment = soap[:assessment]
      @note.plan       = soap[:plan]
    end

    def clinical_note_params
      params.require(:clinical_note).permit(:note_type, :subjective, :objective, :assessment, :plan, :body)
    end
  end
end
