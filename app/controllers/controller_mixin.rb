module ControllerMixin
  def self.included(base)
    base.helper_method :current_user
  end

  private

  def current_user=(user)
    session[:current_user_id] = user ? user.id : nil
  end

  def current_user
    @current_user ||= User.find(session[:current_user_id]) if session[:current_user_id]
  end

  def authenticate
    unless current_user
      session[:quo_vadis_original_url] = request.fullpath
      flash[:notice] = t('quo_vadis.flash.sign_in.before') unless t('quo_vadis.flash.sign_in.before').blank?
      redirect_to sign_in_url
    end
  end
end
