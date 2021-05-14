ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path('../db/migrate', __dir__)
require "rails/test_help"

require 'capybara/rails'
require 'capybara/minitest'

# integration tests or system tests?
#
# system ones use a real browser and can therefore test css layout and js
# but integration ones are faster
class IntegrationTest < ActionDispatch::IntegrationTest
  # include Capybara::DSL
  # include Capybara::Minitest::Assertions

  # include QuoVadis::Engine.routes.url_helpers

  # setup do
  #   @routes = QuoVadis::Engine.routes
  # end

  teardown do
    Capybara.reset_session!
    Capybara.use_default_driver
  end

  # https://philna.sh/blog/2020/01/15/test-signed-cookies-in-rails
  #
  # ActionDispatch::IntegrationTest's `cookies` is a Rack::Test::CookieJar
  # not an ActionDispatch::Cookies::CookieJar, and doesn't have the #encrypted
  # or #signed methods.  So construct an ActionDispatch cookie jar.
  def jar(_session = nil)
    _request, _cookies = if _session
                           [_session.request, _session.cookies]
                         else
                           [@request, cookies]
                         end

    ActionDispatch::Cookies::CookieJar.build(_request, _cookies.to_hash)
  end


  def assert_session_replaced(&block)
    id = jar.encrypted[QuoVadis.cookie_name]

    yield

    _id = jar.encrypted[QuoVadis.cookie_name]

    refute_equal id, _id
    refute QuoVadis::Session.exists? id
    assert QuoVadis::Session.exists? _id
    assert controller.logged_in?
  end
end
