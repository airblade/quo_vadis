# Define a bare test case to use with Capybara
class ActiveSupport::IntegrationCase < ActiveSupport::TestCase
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  teardown do
    Capybara.reset_sessions!
    reset_quo_vadis_configuration
  end

end
