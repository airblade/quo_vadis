module ControllerMixin
  def self.included(base)
    base.helper_method :"current_#{QuoVadis.model_instance_name}"
  end

  protected

  def handle_unverified_request
    super
    cookies.delete :remember_me
  end

  private

  class_eval <<-END, __FILE__, __LINE__ + 1
    # Remembers the authenticated <tt>user</tt> (in this session and future sessions).
    #
    # If you want to sign in a <tt>user</tt> you have just created, call <tt>sign_in</tt>
    # instead.
    def current_#{QuoVadis.model_instance_name}=(user)
      remember_user_in_session user
      remember_user_between_sessions user
    end

    # Returns the authenticated user.
    def current_#{QuoVadis.model_instance_name}
      @current_#{QuoVadis.model_instance_name} ||= find_authenticated_user
    end

    # Does nothing if we already have an authenticated user.  If we don't have an
    # authenticated user, it stores the desired URL and redirects to the sign in URL.
    def authenticate
      unless current_#{QuoVadis.model_instance_name}
        session[:quo_vadis_original_url] = request.fullpath
        flash[:notice] = t('quo_vadis.flash.sign_in.before') unless t('quo_vadis.flash.sign_in.before').blank?
        redirect_to sign_in_url
      end
    end

    # Signs in a user, i.e. remembers them in the session, runs the sign-in hook,
    # and redirects appropriately.
    #
    # This method should be called when you have just authenticated a <tt>user</tt>
    # and you need to sign them in.  For example, if a new user has just signed up,
    # you should call this method to sign them in.
    def sign_in(user)
      prevent_session_fixation
      self.current_#{QuoVadis.model_instance_name} = user
      QuoVadis.signed_in_hook user, self
      redirect_to QuoVadis.signed_in_url(user, original_url, self)
    end

    def remember_user_in_session(user) # :nodoc:
      session[:current_#{QuoVadis.model_instance_name}_id] = user ? user.id : nil
    end

    def find_user_by_cookie # :nodoc:
      #{QuoVadis.model}.find_by_salt(*cookies.signed[:remember_me]) if cookies.signed[:remember_me]
    end

    def find_user_by_session # :nodoc:
      #{QuoVadis.model}.find(session[:current_#{QuoVadis.model_instance_name}_id]) if session[:current_#{QuoVadis.model_instance_name}_id]
    end
  END

  # Returns true if the sign-in process is blocked to the user, false otherwise.
  def blocked?
    QuoVadis.blocked?(self)
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

  # Returns the URL if any which the user tried to visit before being forced to authenticate.
  def original_url
    url = session[:quo_vadis_original_url]
    session[:quo_vadis_original_url] = nil
    url
  end

  def prevent_session_fixation # :nodoc:
    original_flash = flash.inject({}) { |hsh, (k,v)| hsh[k] = v; hsh }
    original_url = session[:quo_vadis_original_url]

    reset_session

    original_flash.each { |k,v| flash[k] = v }
    session[:quo_vadis_original_url] = original_url
  end
end
