module Visits
  class CreateFromAppointmentService < ApplicationService
    def initialize(appointment:, doctor: nil)
      @appointment = appointment
      @doctor = doctor || appointment.doctor
    end

    def call
      return Result.new(success?: false, error: "Appointment not found") unless @appointment
      return Result.new(success?: false, error: "Visit already exists for this appointment") if @appointment.visit.present?

      visit = Visit.new(
        appointment: @appointment,
        patient: @appointment.patient,
        doctor: @doctor,
        visit_date: Date.current,
        visit_type: determine_visit_type,
        chief_complaint: @appointment.reason,
        status: :in_progress
      )

      if visit.save
        @appointment.update(status: :in_progress) if @appointment.confirmed? || @appointment.checked_in?
        Result.new(success?: true, data: visit)
      else
        Result.new(success?: false, error: visit.errors.full_messages.join(", "))
      end
    end

    private

    def determine_visit_type
      case @appointment.appointment_type
      when "emergency" then :emergency
      when "follow_up" then :follow_up
      when "recurring" then :dialysis
      else :outpatient
      end
    end
  end
end
