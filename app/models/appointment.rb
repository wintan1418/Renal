class Appointment < ApplicationRecord
  belongs_to :patient, class_name: "User"
  belongs_to :doctor, class_name: "User"
  belongs_to :service
  belongs_to :department, optional: true
  belongs_to :recurring_schedule, optional: true
  belongs_to :checked_in_by, class_name: "User", optional: true

  has_one :visit, dependent: :nullify

  enum :status, {
    pending: 0,
    confirmed: 1,
    checked_in: 2,
    in_progress: 3,
    completed: 4,
    cancelled: 5,
    no_show: 6
  }

  enum :appointment_type, {
    walk_in: 0,
    scheduled: 1,
    follow_up: 2,
    emergency: 3,
    recurring: 4
  }

  validates :scheduled_date, :start_time, presence: true
  validates :patient_id, :doctor_id, :service_id, presence: true
  validate :no_double_booking

  scope :upcoming, -> { where("scheduled_date >= ?", Date.current).order(:scheduled_date, :start_time) }
  scope :today, -> { where(scheduled_date: Date.current) }
  scope :for_doctor, ->(doctor_id) { where(doctor_id: doctor_id) }
  scope :for_patient, ->(patient_id) { where(patient_id: patient_id) }
  scope :active_statuses, -> { where(status: [ :pending, :confirmed, :checked_in, :in_progress ]) }

  before_create :assign_queue_number
  before_save :set_department_from_service

  audited

  def duration_minutes
    service&.duration_minutes || 30
  end

  def end_time_calculated
    return nil if start_time.blank?

    start_time + duration_minutes.minutes
  end

  private

  def no_double_booking
    return if doctor_id.blank? || scheduled_date.blank? || start_time.blank?

    calculated_end = end_time_calculated
    return if calculated_end.nil?

    overlapping = Appointment
      .where(doctor_id: doctor_id, scheduled_date: scheduled_date)
      .where.not(status: :cancelled)
      .where.not(id: id)

    overlapping.each do |appt|
      appt_end = appt.end_time || appt.end_time_calculated
      next if appt_end.nil?

      if start_time < appt_end && calculated_end > appt.start_time
        errors.add(:base, "Doctor already has an appointment during this time slot")
        break
      end
    end
  end

  def assign_queue_number
    last_queue = Appointment
      .where(doctor_id: doctor_id, scheduled_date: scheduled_date)
      .maximum(:queue_number) || 0

    self.queue_number = last_queue + 1
  end

  def set_department_from_service
    self.department_id = service&.department_id if department_id.blank? && service.present?
  end
end
