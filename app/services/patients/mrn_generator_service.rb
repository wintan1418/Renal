module Patients
  class MrnGeneratorService < ApplicationService
    PREFIX = "HR"

    def initialize
    end

    def call
      year = Date.current.year
      last_mrn = PatientProfile
        .where("medical_record_number LIKE ?", "#{PREFIX}-#{year}-%")
        .order(medical_record_number: :desc)
        .pick(:medical_record_number)

      if last_mrn
        last_number = last_mrn.split("-").last.to_i
        next_number = last_number + 1
      else
        next_number = 1
      end

      mrn = format("#{PREFIX}-%04d-%05d", year, next_number)
      Result.new(success?: true, data: mrn)
    end
  end
end
