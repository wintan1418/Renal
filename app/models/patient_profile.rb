class PatientProfile < ApplicationRecord
  belongs_to :user

  enum :gender, { male: 0, female: 1, other: 2 }
  enum :blood_group, { a_positive: 0, a_negative: 1, b_positive: 2, b_negative: 3, ab_positive: 4, ab_negative: 5, o_positive: 6, o_negative: 7 }
  enum :genotype, { aa: 0, as_genotype: 1, ss: 2, ac: 3, sc: 4 }
  enum :marital_status, { single: 0, married: 1, divorced: 2, widowed: 3 }
  enum :ckd_stage, { stage_1: 1, stage_2: 2, stage_3a: 3, stage_3b: 4, stage_4: 5, stage_5: 6 }, prefix: :ckd
  enum :transplant_status, { none: 0, waitlisted: 1, transplanted: 2 }, prefix: :transplant

  validates :user_id, uniqueness: true
  validates :medical_record_number, presence: true, uniqueness: true

  before_validation :generate_mrn, on: :create

  audited associated_with: :user

  def blood_group_display
    return nil unless blood_group
    {
      "a_positive" => "A+", "a_negative" => "A-",
      "b_positive" => "B+", "b_negative" => "B-",
      "ab_positive" => "AB+", "ab_negative" => "AB-",
      "o_positive" => "O+", "o_negative" => "O-"
    }[blood_group]
  end

  def genotype_display
    return nil unless genotype
    { "aa" => "AA", "as_genotype" => "AS", "ss" => "SS", "ac" => "AC", "sc" => "SC" }[genotype]
  end

  def age
    return nil unless date_of_birth
    now = Time.current.to_date
    now.year - date_of_birth.year - (now.yday < date_of_birth.yday ? 1 : 0)
  end

  private

  def generate_mrn
    return if medical_record_number.present?
    loop do
      self.medical_record_number = "HRM-#{SecureRandom.hex(3).upcase}"
      break unless self.class.exists?(medical_record_number: medical_record_number)
    end
  end
end
