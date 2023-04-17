# frozen_string_literal: true

module QuoVadis
  class PasswordResetsController < QuoVadisController

    # form where user enters their identifier
    def new
    end


    # generate and email an otp
    def create
      account = QuoVadis.find_account_by_identifier_in_params params

      # The recommendation is to show the user the same message whether
      # or not their account was found.  This favours privacy over
      # helpfulness and is the default.
      #
      # If you would prefer helpfulness over privacy -- perhaps the user
      # simply typo'd their identifier -- set the `unknown` flash message
      # to something helpful.
      message_known   = QuoVadis.translate('flash.password_reset.create')
      message_unknown = QuoVadis.translate('flash.password_reset.unknown')

      if message_known == message_unknown
        flash[:notice] = message_known
      elsif account
        flash[:notice] = message_known
      else
        flash[:alert] = message_unknown
      end

      if account
        session[:account_resetting_password] = account.id

        expiration = QuoVadis.password_reset_otp_lifetime.from_now.to_i
        session[:password_reset_expires_at] = expiration

        otp = account.otp_for_password_reset(expiration)

        QuoVadis.deliver :reset_password, {email: account.model.email, otp: otp}
      end

      redirect_to edit_password_reset_path
    end


    # form for otp and new password
    def edit
      @password = QuoVadis::Password.new
    end


    # update password if otp and password are valid
    def update
      account = find_account_resetting_password_from_session

      unless account
        redirect_to new_password_reset_path
        return
      end

      expiry = session[:password_reset_expires_at]

      if Time.current.to_i > expiry
        redirect_to new_password_reset_path, alert: QuoVadis.translate('flash.password_reset.expired')
        return
      end

      unless account.verify_password_reset(params[:password][:otp], expiry)
        redirect_to new_password_reset_path, alert: QuoVadis.translate('flash.password_reset.invalid')
        return
      end

      @password = account.password
      unless @password.reset(params[:password][:password], params[:password][:password_confirmation])
        render :edit, status: :unprocessable_entity
        return
      end

      session.delete :account_resetting_password
      session.delete :password_reset_expires_at

      qv.log account, Log::PASSWORD_RESET
      QuoVadis.notify :password_reset_notification, email: account.model.email

      login account.model, true

      redirect_to qv.path_after_authentication, notice: QuoVadis.translate('flash.password_reset.reset')
    end

    private

    def find_account_resetting_password_from_session
      if session[:account_resetting_password]
        Account.find(session[:account_resetting_password])
      end
    end
  end
end
