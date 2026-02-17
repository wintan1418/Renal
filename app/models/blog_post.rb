class BlogPost < ApplicationRecord
  belongs_to :author, class_name: "User"
  has_one_attached :featured_image
  has_rich_text :rich_body

  enum :category, { kidney_health: 0, nutrition: 1, dialysis_tips: 2, transplant: 3, general_health: 4, news: 5 }
  enum :status, { draft: 0, published: 1, archived: 2 }

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug

  scope :recent, -> { published.order(published_at: :desc) }

  def to_param
    slug
  end

  def reading_time
    words = (body.to_s.split.size + rich_body.to_s.split.size)
    [ (words / 200.0).ceil, 1 ].max
  end

  private

  def generate_slug
    self.slug = title.to_s.parameterize if slug.blank? && title.present?
  end
end
