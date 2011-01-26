QuoVadis.configure do |config|

  #
  # Redirection URLs
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

  # The URL to redirect the user to after s/he signs out.
  config.signed_out_url = :root


  #
  # Hooks
  #

  # Code to run when the user has signed in.  E.g.:
  #
  # config.signed_in_hook = Proc.new do |user, controller|
  #   user.increment! :sign_in_count  # assuming this attribute exists
  # end
  config.signed_in_hook = nil

  # Code to run when someone has tried but failed to sign in.  E.g.:
  #
  # config.failed_sign_in_hook = Proc.new do |controller|
  #   logger.info "Failed sign in from #{controller.request.remote_ip}"
  # end
  config.failed_sign_in_hook = nil

  # Code to run just before the user has signed out.  E.g.:
  #
  # config.signed_out_hook = Proc.new do |user, controller|
  #   controller.session.reset
  # end
  config.signed_out_hook = nil


  #
  # Miscellaneous
  #

  # Layout for the sign-in view.  Pass a string or a symbol.
  config.layout = 'application'

end
