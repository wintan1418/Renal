class Public::BlogPostsController < ApplicationController
  layout "public"

  def index
    @pagy, @posts = pagy(BlogPost.recent, items: 9)
  end

  def show
    @post = BlogPost.published.find_by!(slug: params[:id])
    @post.increment!(:views_count)
  end
end
