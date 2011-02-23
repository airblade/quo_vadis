require 'test_helper'

class CookieTest < ActiveSupport::IntegrationCase

  test 'authenticated user is remembered between browser sessions' do
    user_factory 'Bob', 'bob', 'secret'
    sign_in_as 'bob', 'secret'
    close_browser
    visit root_path
    within '#topnav' do
      assert page.has_content?('You are signed in as Bob.')
    end
    assert page.has_no_css?('div.flash')
  end

  test "signing in updates the remember-me cookie's expiry time" do
    user_factory 'Bob', 'bob', 'secret'
    sign_in_as 'bob', 'secret'
    cookie_a = get_cookie('remember_me')
    assert_equal 2.weeks.from_now.httpdate, cookie_a.expires.httpdate
    close_browser
    sleep 1  # cookie expiry times are accurate to 1 second.

    sign_in_as 'bob', 'secret'
    cookie_b = get_cookie('remember_me')
    assert cookie_b.expires > cookie_a.expires
    assert_equal cookie_a.value, cookie_b.value
  end

  test 'signing out prevents the user being remembered in the next browser session' do
    user_factory 'Bob', 'bob', 'secret'
    sign_in_as 'bob', 'secret'
    visit sign_out_path
    close_browser
    visit new_article_path
    assert_equal sign_in_path, current_path
  end

  test "changing user's password prevents user being remembered in the next browser session" do
    user_factory 'Bob', 'bob', 'secret'
    sign_in_as 'bob', 'secret'
    cookie = get_cookie('remember_me')
    User.last.update_attributes! :password => 'topsecret'
    close_browser
    visit new_article_path
    assert_equal sign_in_path, current_path
  end

  test 'length of time user is remembered can be configured' do
    QuoVadis.remember_for = 1.second
    user_factory 'Bob', 'bob', 'secret'
    sign_in_as 'bob', 'secret'
    close_browser
    sleep 2
    visit new_article_path
    assert_equal sign_in_path, current_path
  end

  test 'remembering user between sessions can be turned off' do
    QuoVadis.remember_for = nil
    user_factory 'Bob', 'bob', 'secret'
    sign_in_as 'bob', 'secret'
    close_browser
    visit new_article_path
    assert_equal sign_in_path, current_path
  end
end
