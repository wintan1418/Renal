class Page < ApplicationRecord
  belongs_to :author, class_name: "User", optional: true
  has_rich_text :rich_body

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug

  scope :published, -> { where(published: true) }

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
  end
end
