class PasswordResetsController < ApplicationController
  def new
  end

  def edit
  end
end
class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update] 
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  def new
  end

  def create
    @users = User.find_by(email: params[:password_reset][:email].downcase) 
    if @users
      @users.create_reset_digest
      @users.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions" 
      redirect_to root_url
    else
    flash.now[:danger] = "Email address not found"
    render 'new' 
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @usesr.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @users.update_attributes(user_params)
      log_in @users
      flash[:success] = "Password has been reset."
      redirect_to @users
    else
      render 'edit' 
    end
  end
    

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end  

  def get_user
    @users = User.find_by(email: params[:email])
  end
        # Confirms a valid user.
  def valid_user
    unless (@users && @users.activated? && @users.authenticated?(:reset, params[:id])) 
      redirect_to root_url
    end 
  end

  def check_expiration
    if @users.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_url
    end 
  end
end