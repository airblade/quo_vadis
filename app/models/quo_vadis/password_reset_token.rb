# frozen_string_literal: true

module QuoVadis
  class PasswordResetToken < Token
    class << self

      def expires_at
        QuoVadis.password_reset_token_lifetime.from_now.to_i
      end

      def data_for_hmac(data, account)
        "#{data}-#{account.password.password_digest}"
      end

    end
  end
end
