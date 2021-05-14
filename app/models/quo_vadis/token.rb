# frozen_string_literal: true

module QuoVadis
  class Token
    extend Hmacable

    class << self

      def generate(account)
        public_data = "#{account.id}-#{expires_at}"
        data = data_for_hmac public_data, account
        "#{public_data}--#{compute_hmac(data)}"
      end

      def find_account(token)
        provided_public_data, provided_hmac = token.split '--'
        id, expires_at = provided_public_data.split '-'
        account = Account.find id
        data = data_for_hmac provided_public_data, account
        actual_hmac = compute_hmac data
        return nil unless timing_safe_eql? provided_hmac, actual_hmac
        return nil if expires_at.to_i < Time.current.to_i
        account
      rescue
        nil
      end

      private

      attr_reader :account

      def expires_at
        raise NotImplementedError
      end

      def data_for_hmac(public_data, account)
        raise NotImplementedError
      end

    end
  end
end
