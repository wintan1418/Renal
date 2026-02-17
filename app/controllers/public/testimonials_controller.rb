class Public::TestimonialsController < ApplicationController
  layout "public"

  def index
    @testimonials = Testimonial.approved.order(created_at: :desc)
  end
end
