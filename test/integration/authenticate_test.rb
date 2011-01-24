require 'test_helper'

class AuthenticationTest < ActiveSupport::IntegrationCase

  test 'action not requiring authentication' do
    visit articles_path

    assert_equal articles_path, current_path
    within 'h1' do
      assert page.has_content?('Articles')
    end
  end

  test 'action requiring authentication' do
    # try to see page
    visit new_article_path
    
    # test we need to authenticate
    assert_equal sign_in_path, current_path
    within '.flash.notice' do
      assert page.has_content? 'Please sign in first.'
    end

    # sign in
    user_factory 'Bob', 'bob', 'secret'
    sign_in_as 'bob', 'secret'
    visit new_article_path

    # test we can now see page
    assert_equal new_article_path, current_path
    within 'h1' do
      assert page.has_content?('New Article')
    end
  end
end
