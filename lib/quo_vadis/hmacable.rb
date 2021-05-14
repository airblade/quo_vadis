# frozen_string_literal: true

require 'openssl'


# Much of this comes from Rodauth.
module QuoVadis
  module Hmacable

    def compute_hmac(data)
      OpenSSL::HMAC.hexdigest 'SHA256', hmac_secret, data
    end

    def timing_safe_eql?(provided, actual)
      provided = provided.to_s
      Rack::Utils.secure_compare(provided.ljust(actual.length), actual) && provided.length == actual.length
    end

    private

    def hmac_secret
      Rails.application.secret_key_base
    end

  end
end
