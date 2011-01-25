require 'test_helper'

class SignInTest < ActiveSupport::IntegrationCase

  teardown do
    Capybara.reset_sessions!
  end

  test 'failed sign in' do
    sign_in_as 'bob', 'secret'

    assert_equal sign_in_path, current_path
    within '.flash.alert' do
      assert page.has_content?('Sorry, we did not recognise you.')
    end
  end

  test 'successful sign in' do
    user_factory 'Bob', 'bob', 'secret'
    sign_in_as 'bob', 'secret'

    assert_equal root_path, current_path
    within '.flash.notice' do
      assert page.has_content?('You have successfully signed in.')
    end
  end

end
