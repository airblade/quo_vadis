# frozen_string_literal: true

module QuoVadis

  # A session is started once a user logs in with a password,
  # regardless of whether 2FA is also required.
  class Session < ActiveRecord::Base
    include IpMasking

    belongs_to :account
    validates :ip, presence: true

    attribute :last_seen_at, :datetime, default: -> { Time.now.utc }

    def logout_other_sessions
      account.sessions.reject { |s| s == self }.each &:destroy
    end

    def authenticated_with_second_factor
      touch :second_factor_at
    end

    def reset_authenticated_with_second_factor
      update second_factor_at: nil
    end

    def second_factor_authenticated?
      !second_factor_at.nil?
    end

    def expired?
      exceeded_lifetime? || exceeded_idle_timeout?
    end

    def replace
      destroy.dup.tap &:save
    end

    private

    def exceeded_lifetime?
      return false if browser_session?
      lifetime_expires_at < Time.now.utc
    end

    def browser_session?
      lifetime_expires_at.nil?
    end

    def exceeded_idle_timeout?
      return false if QuoVadis.session_idle_timeout == :lifetime
      QuoVadis.session_idle_timeout.since(last_seen_at) < Time.now.utc
    end
  end
end
