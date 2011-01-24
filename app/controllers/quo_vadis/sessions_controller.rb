class QuoVadis::SessionsController < ApplicationController

  # sign in
  def new
    render 'sessions/new'
  end

  # sign in
  def create
    if user = User.authenticate(params[:username], params[:password])
      self.current_user = user
      QuoVadis.signed_in_hook user, request
      redirect_to QuoVadis.signed_in_url(user), :notice => t('quo_vadis.flash.after_sign_in')
    else
      flash.now[:alert] = t('quo_vadis.flash.failed_sign_in')
      render 'sessions/new'
    end
  end

  # sign out
  def destroy
    self.current_user = nil
    redirect_to QuoVadis.signed_out_url, :notice => t('quo_vadis.flash.sign_out')
  end

end
