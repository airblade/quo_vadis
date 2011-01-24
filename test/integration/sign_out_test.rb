require 'test_helper'

class SignOutTest < ActiveSupport::IntegrationCase

  test 'sign out' do
    user_factory 'Bob', 'bob', 'secret'
    sign_in_as 'bob', 'secret'
    visit sign_out_path

    assert_equal root_path, current_path
    within '.flash.notice' do
      assert page.has_content?('You have successfully signed out.')
    end
  end

end
