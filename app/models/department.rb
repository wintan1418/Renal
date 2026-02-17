class Department < ApplicationRecord
  belongs_to :head_of_department, class_name: "User", optional: true
  has_many :staff_profiles
  has_many :services, dependent: :destroy
  has_many :appointments

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }

  audited
end
