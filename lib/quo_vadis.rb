require 'quo_vadis/engine'
require 'active_support/core_ext/numeric/time'

module QuoVadis

  # The model we want to authenticate.
  mattr_accessor :model # :nodoc:
  @@model = 'User'

  def self.model_class # :nodoc
    @@model.constantize
  end

  def self.model_instance_name # :nodoc
    @@model.tableize.singularize  # e.g. 'user'
  end


  #
  # Sign in
  #

  # The URL to redirect the user to after s/he signs in.
  mattr_accessor :signed_in_url
  @@signed_in_url = :root

  # Whether the `:signed_in_url` should override the URL the user was trying
  # to reach when they were made to authenticate.
  mattr_accessor :override_original_url
  @@override_original_url = false

  def self.signed_in_url(user, original_url, controller) # :nodoc:
    if original_url && !@@override_original_url
      original_url
    else
      @@signed_in_url.respond_to?(:call) ?  @@signed_in_url.call(user, controller) : @@signed_in_url
    end
  end

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

  # How long to remember user across browser sessions.
  mattr_accessor :remember_for
  @@remember_for = 2.weeks


  # Whether the sign-in process is blocked to the user.
  mattr_writer :blocked
  @@blocked = false

  def self.blocked?(controller) # :nodoc:
    @@blocked.respond_to?(:call) ? @@blocked.call(controller) : @@blocked
  end


  #
  # Sign out
  #

  # The URL to redirect the user to after s/he signs out.
  mattr_accessor :signed_out_url
  @@signed_out_url = :root

  def self.signed_out_url(controller) # :nodoc:
    @@signed_out_url.respond_to?(:call) ? @@signed_out_url.call(controller) : @@signed_out_url
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
