class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    users = User.all
    users = users.where(role: params[:role]) if params[:role].present?
    users = users.where("first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
    @pagy, @users = pagy(users.order(created_at: :desc), items: 20)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.skip_confirmation!
    if @user.save
      redirect_to admin_user_path(@user), notice: "User created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    update_params = user_params
    update_params.delete(:password) if update_params[:password].blank?
    update_params.delete(:password_confirmation) if update_params[:password_confirmation].blank?

    if update_params[:password].blank?
      if @user.update_without_password(update_params)
        redirect_to admin_user_path(@user), notice: "User updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    else
      if @user.update(update_params)
        redirect_to admin_user_path(@user), notice: "User updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @user.update(active: false)
    redirect_to admin_users_path, notice: "User deactivated."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :role, :active, :password, :password_confirmation, :avatar)
  end
end
