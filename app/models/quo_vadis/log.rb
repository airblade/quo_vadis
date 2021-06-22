# frozen_string_literal: true

module QuoVadis
  class Log < ActiveRecord::Base
    include IpMasking

    LOGIN_SUCCESS          = 'login.success'
    LOGIN_FAILURE          = 'login.failure'
    LOGIN_UNKNOWN          = 'login.unknown'
    TOTP_SETUP             = 'totp.setup'
    TOTP_SUCCESS           = 'totp.success'
    TOTP_FAILURE           = 'totp.failure'
    TOTP_REUSE             = 'totp.reuse'
    RECOVERY_CODE_SUCCESS  = 'recovery_code.success'
    RECOVERY_CODE_FAILURE  = 'recovery_code.failure'
    RECOVERY_CODE_GENERATE = 'recovery_code.generate'
    TWOFA_DEACTIVATED      = '2fa.deactivated'
    IDENTIFIER_CHANGE      = 'identifier.change'
    EMAIL_CHANGE           = 'email.change'
    PASSWORD_CHANGE        = 'password.change'
    PASSWORD_RESET         = 'password.reset'
    ACCOUNT_CONFIRMATION   = 'account.confirmation'
    LOGOUT_OTHER           = 'logout.other'
    LOGOUT                 = 'logout.self'

    ACTIONS = [
      LOGIN_SUCCESS,
      LOGIN_FAILURE,
      LOGIN_UNKNOWN,
      TOTP_SETUP,
      TOTP_SUCCESS,
      TOTP_FAILURE,
      TOTP_REUSE,
      RECOVERY_CODE_SUCCESS,
      RECOVERY_CODE_FAILURE,
      RECOVERY_CODE_GENERATE,
      TWOFA_DEACTIVATED,
      IDENTIFIER_CHANGE,
      EMAIL_CHANGE,
      PASSWORD_CHANGE,
      PASSWORD_RESET,
      ACCOUNT_CONFIRMATION,
      LOGOUT_OTHER,
      LOGOUT
    ]

    belongs_to :account, optional: true  # optional only for LOGIN_UNKNOWN

    validates :action, inclusion: {in: ACTIONS}

    scope :new_to_old, -> { order created_at: :desc }

    scope :page, ->(page, per_page) {
      limit(per_page).offset((page - 1) * per_page)
    }
  end
end
