class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :lockable, :trackable

  enum :role, { patient: 0, receptionist: 1, nurse: 2, doctor: 3, admin: 4 }, default: :patient

  has_one :staff_profile, dependent: :destroy
  has_one :patient_profile, dependent: :destroy
  has_one_attached :avatar

  has_many :doctor_schedules, foreign_key: :doctor_id, dependent: :destroy
  has_many :schedule_exceptions, foreign_key: :doctor_id, dependent: :destroy
  has_many :appointments_as_patient, class_name: "Appointment", foreign_key: :patient_id, dependent: :destroy
  has_many :appointments_as_doctor, class_name: "Appointment", foreign_key: :doctor_id, dependent: :destroy
  has_many :recurring_schedules_as_patient, class_name: "RecurringSchedule", foreign_key: :patient_id
  has_many :recurring_schedules_as_doctor, class_name: "RecurringSchedule", foreign_key: :doctor_id

  # Phase 3 - Medical Records & Clinical Workflow
  has_many :visits_as_patient, class_name: "Visit", foreign_key: :patient_id, dependent: :destroy
  has_many :visits_as_doctor, class_name: "Visit", foreign_key: :doctor_id, dependent: :destroy
  has_many :clinical_notes, foreign_key: :author_id, dependent: :destroy
  has_many :vital_signs_as_patient, class_name: "VitalSign", foreign_key: :patient_id, dependent: :destroy
  has_many :vital_signs_recorded, class_name: "VitalSign", foreign_key: :recorded_by_id, dependent: :nullify
  has_many :diagnoses, foreign_key: :patient_id, dependent: :destroy
  has_many :allergies, foreign_key: :patient_id, dependent: :destroy
  has_many :medications, foreign_key: :patient_id, dependent: :destroy
  has_many :lab_orders_as_patient, class_name: "LabOrder", foreign_key: :patient_id, dependent: :destroy
  has_many :lab_orders_ordered, class_name: "LabOrder", foreign_key: :ordered_by_id, dependent: :nullify
  has_many :lab_results, foreign_key: :patient_id, dependent: :destroy
  has_many :prescriptions_as_patient, class_name: "Prescription", foreign_key: :patient_id, dependent: :destroy
  has_many :prescriptions_written, class_name: "Prescription", foreign_key: :prescribed_by_id, dependent: :nullify

  # Phase 4 - Dialysis
  has_many :dialysis_sessions_as_patient, class_name: "DialysisSession", foreign_key: :patient_id, dependent: :destroy
  has_many :dialysis_sessions_as_doctor, class_name: "DialysisSession", foreign_key: :doctor_id, dependent: :nullify
  has_many :dialysis_sessions_as_nurse, class_name: "DialysisSession", foreign_key: :nurse_id, dependent: :nullify

  # Phase 5 - Billing & Notifications
  has_many :invoices_as_patient, class_name: "Invoice", foreign_key: :patient_id, dependent: :destroy
  has_many :payments_as_patient, class_name: "Payment", foreign_key: :patient_id, dependent: :destroy
  has_many :insurance_claims, foreign_key: :patient_id, dependent: :destroy
  has_many :notifications_received, class_name: "Notification", foreign_key: :recipient_id, dependent: :destroy
  has_many :notifications_sent, class_name: "Notification", foreign_key: :actor_id, dependent: :nullify
  has_many :notification_preferences, dependent: :destroy
  has_many :conversations_as_patient, class_name: "Conversation", foreign_key: :patient_id, dependent: :destroy
  has_many :conversation_participants, dependent: :destroy
  has_many :conversations, through: :conversation_participants
  has_many :messages_sent, class_name: "Message", foreign_key: :sender_id, dependent: :nullify

  # Phase 6 - Extras
  has_many :telemedicine_sessions_as_patient, class_name: "TelemedicineSession", foreign_key: :patient_id, dependent: :destroy
  has_many :telemedicine_sessions_as_doctor, class_name: "TelemedicineSession", foreign_key: :doctor_id, dependent: :nullify
  has_many :patient_surveys, foreign_key: :patient_id, dependent: :destroy
  has_many :transplant_waitlist_entries, foreign_key: :patient_id, dependent: :destroy
  has_many :diet_logs, foreign_key: :patient_id, dependent: :destroy
  has_many :emergency_contacts, foreign_key: :patient_id, dependent: :destroy

  accepts_nested_attributes_for :staff_profile
  accepts_nested_attributes_for :patient_profile

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, phone: { allow_blank: true }

  audited except: [ :encrypted_password, :reset_password_token, :reset_password_sent_at,
                     :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at,
                     :current_sign_in_ip, :last_sign_in_ip, :confirmation_token, :confirmed_at,
                     :confirmation_sent_at, :unconfirmed_email, :failed_attempts, :unlock_token, :locked_at ]

  scope :active, -> { where(active: true) }
  scope :staff, -> { where(role: [ :receptionist, :nurse, :doctor, :admin ]) }
  scope :clinical_staff, -> { where(role: [ :doctor, :nurse ]) }
  scope :doctors, -> { where(role: :doctor) }

  def full_name
    "#{first_name} #{last_name}"
  end

  def initials
    "#{first_name[0]}#{last_name[0]}".upcase
  end

  def staff?
    admin? || doctor? || nurse? || receptionist?
  end

  def clinical_staff?
    doctor? || nurse?
  end

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :deactivated
  end
end
