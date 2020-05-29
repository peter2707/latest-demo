class SessionsController < ApplicationController
  def new
  end

  def create
    users = User.find_by(email: params[:session][:email].downcase)
    if users && users.authenticate(params[:session][:password])
      if users.activated?
        log_in users
        params[:session][:remember_me] == '1' ? remember(users) : forget(users)
        redirect_to root_url
      else
        message = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end 
    else
      flash.now[:danger] = 'Invalid email or password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
