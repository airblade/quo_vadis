# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Configure capybara for integration testing
require "capybara/rails"
Capybara.default_driver   = :rack_test
Capybara.default_selector = :css

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

#
# Common methods
#

def sign_in_as(username, password)
  visit sign_in_path
  fill_in 'username', :with => username
  fill_in 'password', :with => password
  click_button 'Sign in'
end

def user_factory(name, username, password)
  User.create! :name => name, :username => username, :password => password
end

def reset_quo_vadis_configuration
  QuoVadis.signed_in_url = :root
  QuoVadis.override_original_url = false
  QuoVadis.signed_out_url = :root
  QuoVadis.signed_in_hook = nil
  QuoVadis.failed_sign_in_hook = nil
  QuoVadis.signed_out_hook = nil
end
