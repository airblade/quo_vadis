# frozen_string_literal: true

module QuoVadis
  class TotpsController < ApplicationController
    before_action :require_password_authentication


    def new
      @totp = authenticated_model.qv_account.build_totp
    end


    def create
      @totp = authenticated_model.qv_account.build_totp(
        key:               totp_params[:key],
        provided_hmac_key: totp_params[:hmac_key]
      )
      if @totp.verify params[:totp][:otp]
        qv.log authenticated_model.qv_account, Log::TOTP_SETUP
        QuoVadis.notify :totp_setup_notification, email: authenticated_model.email
        qv.session_authenticated_with_second_factor
        flash[:recovery_codes] = generate_recovery_codes
        redirect_to recovery_codes_path
      else
        redirect_to new_totp_path, alert: QuoVadis.translate('flash.totp.unverified')
      end
    end


    def challenge
      account = authenticated_model.qv_account

      unless account.has_two_factors?
        redirect_to new_totp_path, alert: QuoVadis.translate('flash.totp.setup') and return
      end

      @totp = account.totp
    end


    def authenticate
      @totp = authenticated_model.qv_account.totp
      if @totp.verify params[:totp]
        qv.log authenticated_model.qv_account, Log::TOTP_SUCCESS
        qv.replace_session
        qv.session_authenticated_with_second_factor
        redirect_to qv.path_after_authentication, notice: QuoVadis.translate('flash.login.success')
      else
        if @totp.reused? params[:totp]
          qv.log authenticated_model.qv_account, Log::TOTP_REUSE
          QuoVadis.notify :totp_reuse_notification, email: authenticated_model.email
        else
          qv.log authenticated_model.qv_account, Log::TOTP_FAILURE
        end
        flash.now[:alert] = QuoVadis.translate('flash.totp.unverified')
        render :challenge, status: :unprocessable_entity
      end
    end


    private

    def totp_params
      params.require(:totp).permit(:key, :hmac_key, :otp)
    end

    def generate_recovery_codes
      authenticated_model.qv_account.generate_recovery_codes
    end

  end
end
