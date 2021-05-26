require 'active_support/core_ext'

QuoVadis.configure do
  password_minimum_length               12
  mask_ips                              false
  cookie_name                           (Rails.env.production? ? '__Host-qv' : 'qv')
  session_lifetime                      :session
  session_lifetime_extend_to_end_of_day false
  session_idle_timeout                  :lifetime
  password_reset_token_lifetime         10.minutes
  accounts_require_confirmation         false
  account_confirmation_token_lifetime   10.minutes
  mail_headers                          ({ from: 'Example App <support@example.com>' })
  enqueue_transactional_emails          true
  app_name                              Rails.app_class.to_s.deconstantize  # for the TOTP QR code
  two_factor_authentication_mandatory   true
  mount_point                           '/'
end
