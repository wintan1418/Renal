class Admin::TestimonialsController < Admin::BaseController
  before_action :set_testimonial, only: [ :show, :edit, :update, :destroy ]

  def index
    testimonials = Testimonial.all
    testimonials = testimonials.where(approved: true) if params[:filter] == "approved"
    testimonials = testimonials.where(approved: false) if params[:filter] == "pending"
    testimonials = testimonials.where("patient_name ILIKE :q OR content ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
    @pagy, @testimonials = pagy(testimonials.order(created_at: :desc), items: 20)
  end

  def show
  end

  def new
    @testimonial = Testimonial.new
  end

  def create
    @testimonial = Testimonial.new(testimonial_params)
    if @testimonial.save
      redirect_to admin_testimonials_path, notice: "Testimonial created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @testimonial.update(testimonial_params)
      redirect_to admin_testimonials_path, notice: "Testimonial updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @testimonial.destroy
    redirect_to admin_testimonials_path, notice: "Testimonial deleted."
  end

  private

  def set_testimonial
    @testimonial = Testimonial.find(params[:id])
  end

  def testimonial_params
    params.require(:testimonial).permit(:patient_name, :content, :rating, :approved, :photo)
  end
end
