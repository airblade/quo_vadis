# frozen_string_literal: true

module QuoVadis
  class SessionsController < QuoVadisController

    # Don't require authentication for the :destroy action so that someone
    # who has logged in via password but not completed 2fa can still log out.
    before_action :require_authentication, except: [:new, :create, :destroy]

    def index
      @qv_session = qv.session
      @qv_sessions = @qv_session.account.sessions.new_to_old
    end


    def new
    end


    def create
      account = QuoVadis.find_account_by_identifier_in_params params

      unless account
        qv.log nil, Log::LOGIN_UNKNOWN, identifier: QuoVadis.identifier_value_in_params(params)
        flash.now[:alert] = QuoVadis.translate 'flash.login.failed'
        render :new, status: :unprocessable_entity
        return
      end

      unless account.password.authenticate params[:password]
        qv.log account, Log::LOGIN_FAILURE
        flash.now[:alert] = QuoVadis.translate 'flash.login.failed'
        render :new, status: :unprocessable_entity
        return
      end

      # no params[:remember]      => use QuoVadis.session_lifetime
      #    params[:remember] == 0 => use :session
      #    params[:remember] == 1 => use QuoVadis.session_lifetime
      browser_session = params[:remember] == '0'

      login account.model, browser_session

      flash[:notice] = QuoVadis.translate 'flash.login.success'

      redirect_to qv.path_after_authentication
    end


    def destroy
      if params[:id]  # other session
        current_qv_session = qv.session
        current_qv_session.account.sessions.destroy params[:id]
        qv.log current_qv_session.account, Log::LOGOUT_OTHER
        flash[:notice] = QuoVadis.translate 'flash.logout.other'
        redirect_to action: :index, status: :see_other
      else  # this session
        qv.log authenticated_model.qv_account, Log::LOGOUT
        qv.logout
        flash[:notice] = QuoVadis.translate 'flash.logout.self'
        redirect_to main_app.root_path, status: :see_other
      end
    end

  end
end
