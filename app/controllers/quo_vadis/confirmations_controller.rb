# frozen_string_literal: true

module QuoVadis
  class ConfirmationsController < QuoVadisController

    def new
      @account = find_pending_account_from_session

      unless @account
        redirect_to qv.path_after_authentication, alert: QuoVadis.translate('flash.confirmation.unknown')
      end
    end


    def create
      @account = find_pending_account_from_session

      unless @account
        redirect_to qv.path_after_authentication, alert: QuoVadis.translate('flash.confirmation.unknown')
        return
      end

      expiry = session[:account_confirmation_expires_at]

      if Time.current.to_i > expiry
        redirect_to confirm_path, alert: QuoVadis.translate('flash.confirmation.expired')
        return
      end

      confirmed = @account.confirm(params[:otp], expiry)

      if !confirmed
        redirect_to confirm_path, alert: QuoVadis.translate('flash.confirmation.invalid')
        return
      end

      qv.log @account, Log::ACCOUNT_CONFIRMATION

      session.delete :account_pending_confirmation
      session.delete :account_confirmation_expires_at

      redirect_to qv.path_after_authentication, notice: QuoVadis.translate('flash.confirmation.confirmed')
    end


    def resend
      @account = find_pending_account_from_session

      unless @account
        redirect_to qv.path_after_authentication, alert: QuoVadis.translate('flash.confirmation.unknown')
      end

      qv.request_confirmation @account.model
      redirect_to confirm_path, notice: QuoVadis.translate('flash.confirmation.sent')
    end


    private

    def find_pending_account_from_session
      if session[:account_pending_confirmation]
        Account.unconfirmed.find(session[:account_pending_confirmation])
      end
    end

  end
end
