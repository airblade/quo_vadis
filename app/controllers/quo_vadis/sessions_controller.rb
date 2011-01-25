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
      redirect_to QuoVadis.signed_in_url(user, original_url), :notice => t('quo_vadis.flash.after_sign_in')
    else
      QuoVadis.failed_sign_in_hook request
      flash.now[:alert] = t('quo_vadis.flash.failed_sign_in')
      render 'sessions/new'
    end
  end

  # sign out
  def destroy
    QuoVadis.signed_out_hook current_user, request
    self.current_user = nil
    redirect_to QuoVadis.signed_out_url, :notice => t('quo_vadis.flash.sign_out')
  end

  private

  def original_url
    url = session[:quo_vadis_original_url]
    session[:quo_vadis_original_url] = nil
    url
  end

end
