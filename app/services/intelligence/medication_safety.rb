module Intelligence
  # Screens a patient's medication list for renal-safety concerns: nephrotoxic
  # agents, drugs needing dose adjustment in CKD, and conflicts with recorded
  # allergies. A curated rule base — no external service.
  class MedicationSafety < ApplicationService
    # keyword (matched case-insensitively) => warning
    NEPHROTOXIC = {
      "ibuprofen" => "NSAID — nephrotoxic, avoid in CKD",
      "diclofenac" => "NSAID — nephrotoxic, avoid in CKD",
      "naproxen" => "NSAID — nephrotoxic, avoid in CKD",
      "nsaid" => "NSAID — nephrotoxic, avoid in CKD",
      "gentamicin" => "Aminoglycoside — nephrotoxic, monitor levels",
      "amikacin" => "Aminoglycoside — nephrotoxic, monitor levels",
      "vancomycin" => "Nephrotoxic — monitor trough levels & renal function",
      "tenofovir" => "Can cause renal tubular injury — monitor",
      "contrast" => "Iodinated contrast — risk of contrast nephropathy"
    }.freeze

    DOSE_ADJUST = {
      "metformin" => "Reduce/hold in advanced CKD (lactic-acidosis risk)",
      "gabapentin" => "Renally cleared — reduce dose",
      "atenolol" => "Renally cleared — reduce dose",
      "digoxin" => "Renally cleared — monitor levels",
      "allopurinol" => "Reduce dose in renal impairment"
    }.freeze

    def initialize(patient)
      @patient = patient
    end

    def call
      meds = medication_names
      allergens = @patient.allergies.pluck(:allergen).map(&:downcase)

      warnings = []
      meds.each do |med|
        low = med.downcase
        NEPHROTOXIC.each { |kw, msg| warnings << flag(med, msg, :high) if low.include?(kw) }
        DOSE_ADJUST.each { |kw, msg| warnings << flag(med, msg, :medium) if low.include?(kw) }
        allergens.each do |alg|
          next if alg.blank?
          warnings << flag(med, "Possible conflict with recorded allergy: #{alg.titleize}", :high) if low.include?(alg.split.first)
        end
      end

      { medications: meds, warnings: warnings.uniq { |w| [ w[:medication], w[:message] ] } }
    end

    private

    def flag(med, message, severity)
      { medication: med, message: message, severity: severity }
    end

    def medication_names
      from_meds = @patient.medications.where(active: true).pluck(:name)
      from_rx = PrescriptionItem
                  .joins(:prescription)
                  .where(prescriptions: { patient_id: @patient.id, status: Prescription.statuses[:active] })
                  .pluck(:medication_name)
      (from_meds + from_rx).compact.uniq
    end
  end
end
