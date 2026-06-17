module Clinical
  # Renal (eGFR-adjusted) drug dosing guidance. Curated reference rules — a
  # clinical decision-support aid, not a substitute for prescribing judgement.
  class RenalDoseCalculator < ApplicationService
    # Each drug: normal dose + bands evaluated high→low; first band whose
    # threshold the eGFR meets/exceeds applies. nephrotoxic flag surfaces a warning.
    DRUGS = {
      "Metformin" => { klass: "Antidiabetic", normal: "500–1000 mg twice daily", bands: [
        { min: 45, level: :ok,      text: "Standard dose. Monitor renal function." },
        { min: 30, level: :caution, text: "Max 1000 mg/day. Review risk/benefit." },
        { min: 0,  level: :avoid,   text: "Contraindicated — lactic-acidosis risk." } ] },
      "Gabapentin" => { klass: "Anticonvulsant", normal: "300–1200 mg three times daily", bands: [
        { min: 60, level: :ok,      text: "Standard dosing." },
        { min: 30, level: :caution, text: "Reduce to 200–700 mg twice daily." },
        { min: 15, level: :caution, text: "100–300 mg once daily." },
        { min: 0,  level: :avoid,   text: "100–300 mg after dialysis only." } ] },
      "Atenolol" => { klass: "Beta-blocker", normal: "50–100 mg once daily", bands: [
        { min: 35, level: :ok,      text: "Standard dose." },
        { min: 15, level: :caution, text: "Max 50 mg daily." },
        { min: 0,  level: :caution, text: "25 mg daily; renally cleared." } ] },
      "Digoxin" => { klass: "Cardiac glycoside", normal: "125–250 mcg daily", bands: [
        { min: 50, level: :ok,      text: "Standard dose; monitor levels." },
        { min: 10, level: :caution, text: "Reduce dose 25–75%; monitor levels closely." },
        { min: 0,  level: :caution, text: "Reduce dose 50–90%; monitor levels." } ] },
      "Allopurinol" => { klass: "Xanthine-oxidase inhibitor", normal: "100–300 mg daily", bands: [
        { min: 60, level: :ok,      text: "Standard dose." },
        { min: 30, level: :caution, text: "Max 200 mg daily." },
        { min: 0,  level: :caution, text: "Max 100 mg daily." } ] },
      "Enoxaparin" => { klass: "LMW heparin", normal: "1 mg/kg twice daily", bands: [
        { min: 30, level: :ok,      text: "Standard dose." },
        { min: 0,  level: :caution, text: "Reduce to 1 mg/kg once daily; consider anti-Xa monitoring." } ] },
      "Ciprofloxacin" => { klass: "Fluoroquinolone", normal: "500 mg twice daily", bands: [
        { min: 30, level: :ok,      text: "Standard dose." },
        { min: 0,  level: :caution, text: "250–500 mg every 18–24 h." } ] },
      "Vancomycin" => { klass: "Glycopeptide (nephrotoxic)", normal: "15–20 mg/kg per dose", nephrotoxic: true, bands: [
        { min: 50, level: :caution, text: "Dose by levels; monitor trough & renal function." },
        { min: 0,  level: :caution, text: "Extend interval; dose strictly by levels." } ] },
      "Amoxicillin" => { klass: "Penicillin", normal: "500 mg three times daily", bands: [
        { min: 30, level: :ok,      text: "Standard dose." },
        { min: 10, level: :caution, text: "500 mg twice daily." },
        { min: 0,  level: :caution, text: "500 mg once daily." } ] },
      "Co-trimoxazole" => { klass: "Antibiotic", normal: "960 mg twice daily", bands: [
        { min: 30, level: :ok,      text: "Standard dose." },
        { min: 15, level: :caution, text: "Half dose; monitor potassium." },
        { min: 0,  level: :avoid,   text: "Avoid." } ] },
      "Aciclovir" => { klass: "Antiviral", normal: "400–800 mg five times daily", bands: [
        { min: 25, level: :ok,      text: "Standard dose; ensure hydration." },
        { min: 10, level: :caution, text: "Extend dose interval." },
        { min: 0,  level: :caution, text: "Reduce dose & extend interval." } ] },
      "Morphine" => { klass: "Opioid", normal: "Per pain protocol", bands: [
        { min: 30, level: :caution, text: "Use lowest effective dose." },
        { min: 0,  level: :avoid,   text: "Avoid — active metabolites accumulate. Prefer alternatives." } ] },
      "NSAIDs (e.g. ibuprofen)" => { klass: "NSAID (nephrotoxic)", normal: "—", nephrotoxic: true, bands: [
        { min: 60, level: :caution, text: "Use with caution; avoid chronic use." },
        { min: 0,  level: :avoid,   text: "Avoid — nephrotoxic, worsens kidney function." } ] },
      "Spironolactone" => { klass: "K-sparing diuretic", normal: "25–50 mg daily", bands: [
        { min: 30, level: :caution, text: "Monitor potassium closely." },
        { min: 0,  level: :avoid,   text: "Avoid — hyperkalaemia risk." } ] }
    }.freeze

    def initialize(drug:, egfr:)
      @drug = drug.to_s
      @egfr = egfr
    end

    def self.drug_names = DRUGS.keys

    def call
      info = DRUGS[@drug]
      return { found: false } unless info
      return { found: true, drug: @drug, info: info, egfr: nil, band: nil } if @egfr.blank?

      egfr = @egfr.to_f
      band = info[:bands].find { |b| egfr >= b[:min] } || info[:bands].last
      {
        found: true, drug: @drug, info: info, egfr: egfr,
        stage: ckd_stage(egfr), band: band, nephrotoxic: info[:nephrotoxic]
      }
    end

    private

    def ckd_stage(egfr)
      case egfr
      when 90..Float::INFINITY then "Stage 1 (normal)"
      when 60...90 then "Stage 2 (mild)"
      when 45...60 then "Stage 3a"
      when 30...45 then "Stage 3b"
      when 15...30 then "Stage 4 (severe)"
      else "Stage 5 (kidney failure)"
      end
    end
  end
end
