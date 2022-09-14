# frozen_string_literal: true

module QuoVadis
  class RecoveryCodesController < QuoVadisController
    before_action :require_password_authentication


    def index
      @codes = flash[:recovery_codes]
      @recovery_code_count = account.recovery_codes.count
    end


    def challenge
    end


    def authenticate
      if account.recovery_codes.detect { |rc| rc.authenticate_code params[:code] }
        qv.log account, Log::RECOVERY_CODE_SUCCESS
        qv.replace_session
        qv.session_authenticated_with_second_factor
        reset_totp
        redirect_to qv.path_after_authentication,
          notice: QuoVadis.translate('flash.recovery_code.success',
                                     count: account.recovery_codes.count)
      else
        qv.log account, Log::RECOVERY_CODE_FAILURE
        flash.now[:alert] = QuoVadis.translate('flash.recovery_code.unverified')
        render :challenge, status: :unprocessable_entity
      end
    end


    def generate
      qv.log account, Log::RECOVERY_CODE_GENERATE
      QuoVadis.notify :recovery_codes_generation_notification, email: authenticated_model.email
      account.recovery_codes.delete_all
      flash[:recovery_codes] = account.generate_recovery_codes
      redirect_to quo_vadis.recovery_codes_path
    end


    private

    def account
      authenticated_model.qv_account
    end

    def reset_totp
      account.totp&.destroy
    end
  end
end
