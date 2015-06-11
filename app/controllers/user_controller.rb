class UserController < ApplicationController
  def login
  end

  def authenticate
    begin
      session[:user] = User.find_by(email: params[:user][:email]).authenticate(params[:user][:password])
    rescue 
    end
    unless session[:user]
      flash[:error] = "Invalid Email or Password"
      return redirect_to "/login"
    end
    redirect_to "/"
  end

  def logout
    session.delete(:user)
    redirect_to "/"
  end
end
