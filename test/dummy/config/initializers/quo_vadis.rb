QuoVadis.configure do |config|

  #
  # Sign in
  #

  # The URL to redirect the user to after s/he signs in.
  # Use a proc if the URL depends on the user.  E.g.:
  #
  # config.signed_in_url = Proc.new do |user|
  #   user.admin? ? :admin : :root
  # end
  #
  # See also `:override_original_url`.
  config.signed_in_url = :root

  # Whether the `:signed_in_url` should override the URL the user was trying
  # to reach when they were made to authenticate.
  config.override_original_url = false

  # Code to run when the user has signed in.  E.g.:
  #
  # config.signed_in_hook = Proc.new do |user, controller|
  #   user.increment! :sign_in_count  # assuming this attribute exists
  # end
  config.signed_in_hook = nil

  # Code to run when someone has tried but failed to sign in.  E.g.:
  #
  # config.failed_sign_in_hook = Proc.new do |controller|
  #   Rails.logger.info "Failed sign in from #{controller.request.remote_ip}"
  # end
  config.failed_sign_in_hook = nil

  # How long to remember user across browser sessions.
  # Set to <tt>nil</tt> to never remember user.
  config.remember_for = 2.weeks

  # Code to run to determine whether the sign-in process is blocked to the user.  E.g.:
  #
  # config.blocked = Proc.new do |controller|
  #   # Assuming a SignIn model with scopes for `failed`, `last_day`, `for_ip`.
  #   SignIn.failed.last_day.for_ip(controller.request.remote_ip) >= 5
  # end
  config.blocked = false


  #
  # Sign out
  #

  # The URL to redirect the user to after s/he signs out.
  config.signed_out_url = :root

  # Code to run just before the user has signed out.  E.g.:
  #
  # config.signed_out_hook = Proc.new do |user, controller|
  #   controller.session.reset
  # end
  config.signed_out_hook = nil


  #
  # Forgotten-password Mailer
  #

  # From whom the forgotten-password email should be sent.
  config.from = 'noreply@example.com'

  # Subject of the forgotten-password email.
  config.subject_change_password = 'Change your password'

  # Subject of the invitation email.
  config.subject_invitation = 'Activate your account'


  #
  # Miscellaneous
  #

  # Layout for the sign-in view.  Pass a string or a symbol.
  config.layout = 'application'

end
