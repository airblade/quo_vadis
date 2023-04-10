# frozen_string_literal: true

require 'rotp'

module QuoVadis
  class Account < ActiveRecord::Base

    MAX_NUMBER_OF_RECOVERY_CODES = 5

    belongs_to :model, polymorphic: true

    has_one :password, dependent: :destroy
    has_many :sessions, dependent: :destroy
    has_one :totp, dependent: :destroy
    has_many :recovery_codes, dependent: :destroy
    has_many :logs, dependent: :destroy

    validates :identifier, presence: true, uniqueness: {case_sensitive: false}

    after_update :log_identifier_change, if: :saved_change_to_identifier?
    after_update :notify_identifier_change, if: :saved_change_to_identifier?

    scope :unconfirmed, -> { where confirmed_at: nil }

    def otp_for_confirmation(counter)
      hotp_for_confirmation.at(counter)
    end

    # If the `otp` is valid for the `counter`, confirms the account and returns truthy.
    # Otherwise returns falsey.
    def confirm(otp, counter)
      hotp_for_confirmation.verify(otp, counter) && confirmed!
    end

    def confirmed?
      confirmed_at.present?
    end

    def confirmed!
      touch :confirmed_at
    end

    def has_two_factors?
      password.present? && totp.present?
    end

    # Returns an array of the recovery codes' codes.
    def generate_recovery_codes
      recovery_codes.delete_all
      Array.new(MAX_NUMBER_OF_RECOVERY_CODES) { recovery_codes.create }.map &:code
    end

    def revoke
      password&.destroy
      totp&.destroy
      recovery_codes.destroy_all
      sessions.destroy_all

      Log.create(
        account: self,
        action: Log::REVOKE,
        ip: (CurrentRequestDetails.ip || '')
      )
    end

    private

    def hotp_for_confirmation
      key = ROTP::Base32.encode("#{id}-#{Rails.application.secret_key_base}")
      ROTP::HOTP.new(key)
    end

    def log_identifier_change
      from, to = saved_change_to_identifier
      Log.create(
        account:  self,
        action:   Log::IDENTIFIER_CHANGE,
        ip:       (CurrentRequestDetails.ip || ''),
        metadata: {from: from, to: to}
      )
    end

    def notify_identifier_change
      # No need to notify if the identifier is :email because
      # the email-is-changed notification in the model mixin handles it.
      QuoVadis.notify(:identifier_change_notification,
        email: model.email,
        identifier: QuoVadis.humanise_identifier(model.class.name).downcase
      ) unless QuoVadis.identifier(model.class.name) == :email
    end
  end
end
