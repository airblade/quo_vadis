# frozen_string_literal: true

module QuoVadis
  class AccountConfirmationToken < Token
    class << self

      def expires_at
        QuoVadis.account_confirmation_token_lifetime.from_now.to_i
      end

      def data_for_hmac(data, account)
        "#{data}-#{account.confirmed?}"
      end

    end
  end
end
