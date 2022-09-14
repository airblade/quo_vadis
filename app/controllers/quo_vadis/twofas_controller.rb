# frozen_string_literal: true

module QuoVadis
  class TwofasController < QuoVadisController
    before_action :require_password_authentication

    def show
      @recovery_codes_count = account.recovery_codes.count
    end

    def destroy
      account.totp&.destroy
      account.recovery_codes.delete_all
      account.sessions.each &:reset_authenticated_with_second_factor  # OWASP ASV v4.0, 2.8.6
      qv.log account, Log::TWOFA_DEACTIVATED
      QuoVadis.notify :twofa_deactivated_notification, email: authenticated_model.email
      redirect_to twofa_path, notice: QuoVadis.translate('flash.2fa.invalidated'), status: :see_other
    end

    private

    def account
      authenticated_model.qv_account
    end
  end
end
