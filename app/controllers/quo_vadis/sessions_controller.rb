class QuoVadis::SessionsController < ApplicationController

  # sign in
  def new
    render 'sessions/new'
  end

  # sign in
  def create
    if user = User.authenticate(params[:username], params[:password])
      self.current_user = user
      redirect_to root_url, :notice => 'You have successfully signed in.'
    else
      flash.now[:alert] = 'Sorry, we did not recognise you.'
      render 'sessions/new'
    end
  end

  # sign out
  def destroy
    self.current_user = nil
    redirect_to root_url, :notice => 'You have successfully signed out.'
  end

end
