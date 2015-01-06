class UsersController < ApplicationController
  before_action :signed_in_user
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @listingss = @user.listings.paginate(page: params[:page])

    sale_obj = ListingType.find_by_name('Sale')

    @sale = @user.listings.build(listing_type_id: sale_obj.id)
    @rental = @user.listings.build(listing_type_id: ListingType.find_by(name: 'Rental').id)

    if params[:display].present?
      @display = params[:display]
    else
      @display = 'thumb_list'
    end    
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "User created."
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation, :avatar, :phone, :fax, :biography,
    :address, :license_no, :social_security_no, :commision_split)
    end

    # Before filters

    def correct_user
      @user = User.find(params[:id])      
      redirect_to(root_url) unless current_user?(@user) || current_user.admin?
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
  end
