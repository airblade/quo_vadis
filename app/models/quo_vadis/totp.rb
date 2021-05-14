# frozen_string_literal: true

require 'rotp'
require 'rqrcode'

module QuoVadis
  class Totp < ActiveRecord::Base
    extend Hmacable

    attribute :key, :qv_encrypted, default: -> { ROTP::Base32.random }
    attribute :hmac_key, :string
    attribute :provided_hmac_key, :string

    belongs_to :account

    validate :key_not_tampered_with, if: -> { provided_hmac_key.present? }
    validates :key, presence: true


    def qr_code
      RQRCode::QRCode.new(
        ROTP::TOTP.new(key, issuer: QuoVadis.app_name).provisioning_uri(account.identifier)
      )
    end


    def hmac_key
      self.class.compute_hmac key
    end


    # Returns true and saves the record if `otp` is valid, false otherwise.
    def verify(otp)
      if (_last_used_at = ROTP::TOTP.new(key).verify otp, after: last_used_at)
        self.last_used_at = _last_used_at
        save
      else
        false
      end
    end


    def reused?(otp)
      totp = ROTP::TOTP.new key
      !totp.verify(otp, after: last_used_at) && totp.verify(otp)
    end


    private

    def key_not_tampered_with
      errors.add :key, :invalid unless self.class.timing_safe_eql? provided_hmac_key, hmac_key
    end

  end
end
