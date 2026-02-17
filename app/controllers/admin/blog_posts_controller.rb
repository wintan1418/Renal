class Admin::BlogPostsController < Admin::BaseController
  before_action :set_blog_post, only: [ :show, :edit, :update, :destroy ]

  def index
    blog_posts = BlogPost.includes(:author)
    blog_posts = blog_posts.where(status: params[:status]) if params[:status].present?
    blog_posts = blog_posts.where(category: params[:category]) if params[:category].present?
    blog_posts = blog_posts.where("title ILIKE :q OR excerpt ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
    @pagy, @blog_posts = pagy(blog_posts.order(created_at: :desc), items: 20)
  end

  def show
  end

  def new
    @blog_post = BlogPost.new
  end

  def create
    @blog_post = BlogPost.new(blog_post_params)
    @blog_post.author = current_user
    if @blog_post.save
      redirect_to admin_blog_posts_path, notice: "Blog post created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @blog_post.update(blog_post_params)
      redirect_to admin_blog_posts_path, notice: "Blog post updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog_post.destroy
    redirect_to admin_blog_posts_path, notice: "Blog post deleted."
  end

  private

  def set_blog_post
    @blog_post = BlogPost.find_by!(slug: params[:id])
  end

  def blog_post_params
    params.require(:blog_post).permit(:title, :slug, :excerpt, :body, :category, :status, :published_at, :featured_image, :rich_body)
  end
end
