require_relative 'boot'

# copied from https://github.com/janko/rodauth-rails/blob/master/test/rails_app/config/application.rb

# require "rails/all"
require "active_model/railtie"
require "active_record/railtie"
# require "action_controller/railtie"
# require "action_view/railtie"
require "action_mailer/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

require 'quo_vadis'

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    # config.logger = Logger.new nil
    config.eager_load = true
    config.action_dispatch.show_exceptions = false
    config.action_controller.allow_forgery_protection = false

    config.action_mailer.delivery_method = :test
    config.action_mailer.default_url_options = { host: 'example.com' }
    config.action_mailer.delivery_job = 'ActionMailer::MailDeliveryJob'
  end
end
