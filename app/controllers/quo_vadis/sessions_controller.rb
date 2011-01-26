class QuoVadis::SessionsController < ApplicationController
  layout :quo_vadis_layout

  # sign in
  def new
    render 'sessions/new'
  end

  # sign in
  def create
    if user = User.authenticate(params[:username], params[:password])
      self.current_user = user
      QuoVadis.signed_in_hook user, self
      flash[:notice] = t('quo_vadis.flash.after_sign_in') unless t('quo_vadis.flash.after_sign_in').blank?
      redirect_to QuoVadis.signed_in_url(user, original_url)
    else
      QuoVadis.failed_sign_in_hook self
      flash.now[:alert] = t('quo_vadis.flash.failed_sign_in') unless t('quo_vadis.flash.failed_sign_in').blank?
      render 'sessions/new'
    end
  end

  # sign out
  def destroy
    QuoVadis.signed_out_hook current_user, self
    self.current_user = nil
    flash[:notice] = t('quo_vadis.flash.sign_out') unless t('quo_vadis.flash.sign_out').blank?
    redirect_to QuoVadis.signed_out_url
  end

  private

  def original_url
    url = session[:quo_vadis_original_url]
    session[:quo_vadis_original_url] = nil
    url
  end

  def quo_vadis_layout
    QuoVadis.layout
  end

end
