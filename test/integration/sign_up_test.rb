require 'test_helper'

class SignUpTest < ActiveSupport::IntegrationCase

  test 'sign in of a just-signed-up user' do
    visit new_user_path
    fill_in 'user_name',     :with => 'Robert'
    fill_in 'user_username', :with => 'bob'
    fill_in 'user_password', :with => 'secret'
    click_button 'Sign up'

    assert_equal root_path, current_path

    within '.flash.notice' do
      assert page.has_content?('You have signed up!')
    end

    assert page.has_content?('You are signed in as Robert')
  end

end
