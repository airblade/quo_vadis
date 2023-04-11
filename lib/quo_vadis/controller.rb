# frozen_string_literal: true

module QuoVadis
  module Controller

    def self.included(base)
      base.before_action { CurrentRequestDetails.request = request }

      base.helper_method :authenticated_model, :logged_in?

      # Remember the last activity time so we can timeout idle sessions.
      # This has to be done after that timestamp is checked (in `#authenticated_model`)
      # otherwise sessions could never look idle.
      base.after_action { |controller| controller.qv.touch_session_last_seen_at }
    end


    def require_password_authentication
      if logged_in?
        if QuoVadis.accounts_require_confirmation && !authenticated_model.qv_account.confirmed?
          qv.request_confirmation authenticated_model
          redirect_to quo_vadis.confirm_path
        end
        return
      end
      session[:qv_bookmark] = request.original_fullpath
      redirect_to quo_vadis.login_path, notice: QuoVadis.translate('flash.require_authentication')
    end
    alias_method :require_authentication, :require_password_authentication


    # implies require_password_authentication
    def require_two_factor_authentication
      return require_authentication unless logged_in?
      return unless qv.second_factor_required?
      return if qv.second_factor_authenticated?
      redirect_to quo_vadis.challenge_totps_path and return
    end


    # To be called with a model which has authenticated with a password.
    #
    # browser_session - true: login only for duration of browser session
    #                   false: login for QuoVadis.session_lifetime (which may be browser session anyway)
    def login(model, browser_session = true, metadata: {})
      qv.log model.qv_account, Log::LOGIN_SUCCESS, metadata

      qv.prevent_rails_session_fixation

      lifetime_expires_at = qv.lifetime_expires_at browser_session

      qv_session = model.qv_account.sessions.create!(
        ip:                  request.remote_ip,
        user_agent:          (request.user_agent || ''),
        lifetime_expires_at: lifetime_expires_at
      )

      qv.store_session_id qv_session.id, lifetime_expires_at

      # It is not necessary to set the instance variable here -- the
      # `authenticated_model` method will figure it out from the qv.session --
      # but doing so saves that method a couple of database calls.
      @authenticated_model = model
    end


    def logged_in?
      !authenticated_model.nil?
    end


    # Returns the model instance which has been authenticated by password,
    # or nil.
    def authenticated_model
      return @authenticated_model if defined? @authenticated_model

      # Was not logged in so no need to log out.
      return (@authenticated_model = nil) unless qv.session_id

      _qv_session = qv.session

      # If _qv_session is nil: user was logged in (because qv.session_id is not nil)
      # but now isn't (because there is no corresponding record in the database).  This
      # means the user has remotely logged out this session from another.
      if _qv_session.nil? || _qv_session.expired?
        qv.logout
        return (@authenticated_model = nil)
      end

      @authenticated_model = _qv_session.account.model
    end


    def qv
      @qv_wrapper ||= QuoVadisWrapper.new self
    end


    private


    class QuoVadisWrapper
      def initialize(controller)
        @controller = controller
      end

      # Returns the current QuoVadis session or nil.
      def session
        return nil unless session_id
        QuoVadis::Session.find_by id: session_id
      end

      def session_id
        cookies.encrypted[QuoVadis.cookie_name]
      end

      # Store the session id in an encrypted cookie.
      #
      # Given that the cookie is encrypted, it is safe to store the database primary key of the
      # session rather than a random-value candidate key.
      #
      # expires_at - the end of the QuoVadis session's lifetime (regardless of the idle timeout)
      def store_session_id(id, expires_at)
        cookies.encrypted[QuoVadis.cookie_name] = {
          value:     id,
          httponly:  true,
          secure:    Rails.env.production?,
          same_site: :lax,
          expires:   expires_at  # setting expires_at to nil has the same effect as not setting it
        }
      end

      def clear_session_id
        cookies.delete QuoVadis.cookie_name
      end

      def prevent_rails_session_fixation
        old_session = rails_session.to_hash
        reset_session
        old_session.each { |k,v| rails_session[k] = v }
      end

      def request_confirmation(model)
        rails_session[:account_pending_confirmation] = model.qv_account.id

        expiration = QuoVadis.account_confirmation_otp_lifetime.from_now.to_i
        rails_session[:account_confirmation_expires_at] = expiration

        otp = model.qv_account.otp_for_confirmation(expiration)

        QuoVadis.deliver :account_confirmation, {email: model.email, otp: otp}

        controller.flash[:notice] = QuoVadis.translate 'flash.confirmation.sent'
      end

      # Assumes user is logged in.
      def second_factor_required?
        QuoVadis.two_factor_authentication_mandatory || authenticated_model.qv_account.has_two_factors?
      end

      def second_factor_authenticated?
        session.second_factor_authenticated?
      end

      def touch_session_last_seen_at
        session&.touch :last_seen_at
      end

      def session_authenticated_with_second_factor
        session.authenticated_with_second_factor
      end

      def replace_session
        prevent_rails_session_fixation

        sess = session.replace
        store_session_id sess.id, sess.lifetime_expires_at

        controller.instance_variable_set :@authenticated_model, sess.account.model
      end

      def lifetime_expires_at(browser_session)
        return nil if browser_session
        return nil if QuoVadis.session_lifetime == :session

        t = ActiveSupport::Duration.build(QuoVadis.session_lifetime).from_now
        QuoVadis.session_lifetime_extend_to_end_of_day ? t.end_of_day : t
      end

      def logout
        session&.destroy
        clear_session_id
        reset_session
        controller.instance_variable_set :@authenticated_model, nil
      end

      def logout_other_sessions
        session.logout_other_sessions
      end

      def log(account, action, metadata = {})
        Log.create account: account, action: action, ip: request.remote_ip, metadata: metadata
      end

      def path_after_signup
        return main_app.after_signup_path if main_app.respond_to?(:after_signup_path)
        return main_app.after_login_path  if main_app.respond_to?(:after_login_path)
        return main_app.root_path         if main_app.respond_to?(:root_path)
        raise RuntimeError, 'Missing routes: after_signup_path, after_login_path, root_path; define at least one of them.'
      end

      def path_after_authentication
        if (bookmark = rails_session[:qv_bookmark])
          rails_session.delete :qv_bookmark
          return bookmark
        end
        return main_app.after_login_path if main_app.respond_to?(:after_login_path)
        return main_app.root_path        if main_app.respond_to?(:root_path)
        raise RuntimeError, 'Missing routes: after_login_path, root_path; define at least one of them.'
      end

      def path_after_password_change
        return main_app.after_password_change_path if main_app.respond_to?(:after_password_change_path)
        return main_app.root_path                  if main_app.respond_to?(:root_path)
        raise RuntimeError, 'Missing routes: after_password_change_path, root_path; define at least one of them.'
      end

      private

      attr_reader :controller

      delegate :request, :reset_session, :authenticated_model, :main_app, to: :controller

      def cookies
        controller.send :cookies  # private method
      end

      def rails_session
        controller.session
      end
    end

  end
end
