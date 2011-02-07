require 'quo_vadis/engine'
require 'active_support/core_ext/numeric/time'

module QuoVadis

  #
  # Redirection URLs
  #

  # The URL to redirect the user to after s/he signs in.
  mattr_accessor :signed_in_url
  @@signed_in_url = :root

  # Whether the `:signed_in_url` should override the URL the user was trying
  # to reach when they were made to authenticate.
  mattr_accessor :override_original_url
  @@override_original_url = false

  def self.signed_in_url(user, original_url) # :nodoc:
    if original_url && !@@override_original_url
      original_url
    else
      @@signed_in_url.respond_to?(:call) ?  @@signed_in_url.call(user) : @@signed_in_url
    end
  end

  # The URL to redirect the user to after s/he signs out.
  mattr_accessor :signed_out_url
  @@signed_in_url = :root


  #
  # Hooks
  #

  # Code to run when the user has signed in.
  mattr_accessor :signed_in_hook
  @@signed_in_hook = nil

  def self.signed_in_hook(user, controller) # :nodoc:
    @@signed_in_hook.call(user, controller) if @@signed_in_hook
  end

  # Code to run when someone has tried but failed to sign in.
  mattr_accessor :failed_sign_in_hook
  @@failed_sign_in_hook = nil

  def self.failed_sign_in_hook(controller) # :nodoc:
    @@failed_sign_in_hook.call(controller) if @@failed_sign_in_hook
  end

  # Code to run just before the user has signed out.
  mattr_accessor :signed_out_hook
  @@signed_out_hook = nil

  def self.signed_out_hook(user, controller) # :nodoc:
    @@signed_out_hook.call(user, controller) if @@signed_out_hook
  end


  #
  # Forgotten-password Mailer
  #

  # From whom the forgotten-password email should be sent.
  mattr_accessor :from
  @@from = 'noreply@example.com'

  # Subject of the forgotten-password email.
  mattr_accessor :subject
  @@subject = 'Change your password.'


  #
  # Remember user across browser sessions
  #

  # How long to remember user.
  mattr_accessor :remember_for
  @@remember_for = 2.weeks


  #
  # Miscellaneous
  #

  # Layout for the sign-in view.
  mattr_accessor :layout
  @@layout = nil


  # Configure from the initializer.
  def self.configure
    yield self
  end

end
