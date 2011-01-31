module ControllerMixin
  def self.included(base)
    base.helper_method :current_user
  end

  private

  # Remembers the authenticated <tt>user</tt> in the session.
  #
  # If you want to sign in a <tt>user</tt>, call <tt>QuoVadis::SessionsController#sign_in</tt>
  # instead.
  def current_user=(user)
    session[:current_user_id] = user ? user.id : nil
  end

  # Returns the authenticated user.
  def current_user
    @current_user ||= User.find(session[:current_user_id]) if session[:current_user_id]
  end

  # Does nothing if we already have an authenticated user.  If we don't have an
  # authenticated user, it stores the desired URL and redirects to the sign in URL.
  def authenticate
    unless current_user
      session[:quo_vadis_original_url] = request.fullpath
      flash[:notice] = t('quo_vadis.flash.sign_in.before') unless t('quo_vadis.flash.sign_in.before').blank?
      redirect_to sign_in_url
    end
  end
end
