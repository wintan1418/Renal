module Staff
  class ClinicalNotesController < Staff::BaseController
    def create
      @patient = User.where(role: :patient).find(params[:patient_id])
      @visit = @patient.visits_as_patient.find(params[:visit_id])
      @note = @visit.clinical_notes.new(clinical_note_params)
      @note.author = current_user

      if @note.save
        redirect_to staff_patient_visit_path(@patient, @visit), notice: "Clinical note added."
      else
        redirect_to staff_patient_visit_path(@patient, @visit), alert: @note.errors.full_messages.to_sentence
      end
    end

    private

    def clinical_note_params
      params.require(:clinical_note).permit(:note_type, :subjective, :objective, :assessment, :plan, :body)
    end
  end
end
