class Admin::PagesController < Admin::BaseController
  before_action :set_page, only: [ :show, :edit, :update, :destroy ]

  def index
    pages = Page.all
    pages = pages.where("title ILIKE :q OR body ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
    @pagy, @pages = pagy(pages.order(:title), items: 20)
  end

  def show
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.new(page_params)
    @page.author = current_user
    if @page.save
      redirect_to admin_pages_path, notice: "Page created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @page.update(page_params)
      redirect_to admin_pages_path, notice: "Page updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @page.destroy
    redirect_to admin_pages_path, notice: "Page deleted."
  end

  private

  def set_page
    @page = Page.find_by!(slug: params[:id])
  end

  def page_params
    params.require(:page).permit(:title, :slug, :body, :meta_description, :published, :rich_body)
  end
end
