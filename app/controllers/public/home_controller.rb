class Public::HomeController < ApplicationController
  layout "public"

  def index
    @doctors = User.doctors.active.includes(:staff_profile).limit(4)
    @testimonials = Testimonial.approved.order(created_at: :desc).limit(3)
    @services = Service.active.limit(6)
    @blog_posts = BlogPost.published.order(published_at: :desc).limit(3)
  end

  def about
  end

  def services
    @services = Service.active.includes(:department)
    @departments = Department.active
  end
end
