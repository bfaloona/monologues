class LoginsController < ApplicationController
  
  def new
    session[:user_id] = nil
    render :new
  end
  
  def create
    u = User.authenticate(params[:user][:email], params[:user][:password])
    if u
      session[:user_id] = u.id
      flash[:notice] = nil
      redirect_to root_path
    else
      session[:user_id] = nil
      flash[:notice] = "incorrect email and/or password"
      render :new
    end
  end
    
  def destroy
    session[:user_id] = nil
    flash[:notice] = "See ya!"
    redirect_to root_path
  end
end