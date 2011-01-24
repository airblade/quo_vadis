require 'test_helper'

class HelperTest < ActiveSupport::IntegrationCase

  test 'Current user helper' do
    user_factory 'Bob', 'bob', 'secret'
    sign_in_as 'bob', 'secret'

    within '#topnav' do
      assert page.has_content?('You are signed in as Bob.')
    end
  end

end
