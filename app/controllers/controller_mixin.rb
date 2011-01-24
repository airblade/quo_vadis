module ControllerMixin
  def self.included(base)
    base.helper_method :current_user
  end

  private  # TODO: does this mark them as private once mixed in?

  def current_user=(user)
    session[:current_user_id] = user ? user.id : nil
  end

  def current_user
    @current_user ||= User.find(session[:current_user_id]) if session[:current_user_id]
  end

  def authenticate
    redirect_to sign_in_url, :notice => t('quo_vadis.flash.before_sign_in') unless current_user
  end
end
