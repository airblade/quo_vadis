module ControllerMixin
  def self.included(base)
    base.helper_method :current_user
  end

  def handle_unverified_request
    super
    cookies.delete :remember_me
  end

  private

  # Remembers the authenticated <tt>user</tt> (in this session and future sessions).
  #
  # If you want to sign in a <tt>user</tt>, call <tt>QuoVadis::SessionsController#sign_in</tt>
  # instead.
  def current_user=(user)
    remember_user_in_session user
    remember_user_between_sessions user
  end

  # Returns the authenticated user.
  def current_user
    @current_user ||= find_authenticated_user
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

  def remember_user_in_session(user) # :nodoc:
    session[:current_user_id] = user ? user.id : nil
  end

  def remember_user_between_sessions(user) # :nodoc:
    if user && QuoVadis.remember_for
      cookies.signed[:remember_me] = {
        :value    => [user.id, user.password_salt],
        :expires  => QuoVadis.remember_for.from_now,
        :httponly => true
      }
    else
      cookies.delete :remember_me
    end
  end

  def find_authenticated_user # :nodoc:
    find_user_by_session || find_user_by_cookie
  end

  def find_user_by_cookie # :nodoc:
    User.find_by_salt(*cookies.signed[:remember_me]) if cookies.signed[:remember_me]
  end

  def find_user_by_session # :nodoc:
    User.find(session[:current_user_id]) if session[:current_user_id]
  end
end
