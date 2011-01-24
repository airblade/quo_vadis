QuoVadis.configure do |config|

  # The URL to redirect the user to after s/he signs in.
  # Use a proc if the URL depends on the user.  E.g.:
  #
  # config.signed_in_url = Proc.new do |user|
  #   user.admin? ? :admin : :root
  # end
  #
  config.signed_in_url = :root

  # The URL to redirect the user to after s/he signs out.
  config.signed_out_url = :root

  # Code to run when the user has signed in.  E.g.:
  #
  # config.signed_in_hook = Proc.new do |user, request|
  #   puts "\n\n\n#{user.inspect}\n\n\n"
  # end
  config.signed_in_hook = nil

end
