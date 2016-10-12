# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "www.example.com"

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

def submit_forgotten_details(username)
  visit forgotten_sign_in_path
  fill_in 'username', :with => username
  click_button 'Send me that email'
end

def user_factory(name, username, password, email = nil)
  User.create! :name => name, :username => username, :password => password, :email => email
end

def person_factory(name, username, password, email = nil)
  Person.create! :name => name, :username => username, :password => password, :email => email
end

def reset_quo_vadis_configuration
  QuoVadis.signed_in_url         = :root
  QuoVadis.cookie_domain         = :all
  QuoVadis.override_original_url = false
  QuoVadis.signed_out_url        = :root
  QuoVadis.signed_in_hook        = nil
  QuoVadis.failed_sign_in_hook   = nil
  QuoVadis.signed_out_hook       = nil
  QuoVadis.layout                = 'application'
  QuoVadis.from                  = 'noreply@example.com'
  QuoVadis.remember_for          = 2.weeks
  QuoVadis.blocked               = false
end


#
# Code below from https://github.com/nruth/show_me_the_cookies
#

def delete_cookie(cookie_name)
  cookie_jar.instance_variable_get(:@cookies).reject! do |existing_cookie|
    existing_cookie.name.downcase == cookie_name
  end
end

def get_cookie(cookie_name)
  cookie_jar.instance_variable_get(:@cookies).select do |existing_cookie|
    existing_cookie.name.downcase == cookie_name
  end.first
end

def cookie_jar
  Capybara.current_session.driver.browser.current_session.instance_variable_get(:@rack_mock_session).cookie_jar
end

def close_browser
  delete_cookie Rails.application.config.session_options[:key]
end
