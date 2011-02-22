require 'test_helper'

class CsrfTest < ActionController::IntegrationTest
  setup do
    reset_quo_vadis_configuration
  end

  test 'cookies are destroyed on unverified requests' do
    user_factory 'Bob', 'bob', 'secret'
    # sign in
    post sign_in_path, :username => 'bob', :password => 'secret'
    get new_article_path
    assert_equal new_article_path, path

    # mimic closing browser
    session.clear

    # assert remember me cookie is still set
    assert !cookies['remember_me'].blank?

    # go to new article page, to start new session, and create article
    get_via_redirect new_article_path
    assert_equal new_article_path, path
    assert_difference 'Article.count' do
      post articles_path, :article => {:title => 'My article'}, :authenticity_token => session[:_csrf_token]
    end

    # assert remember me cookie is still set
    assert !cookies['remember_me'].blank?

    # make unverified request
    assert_no_difference 'Article.count' do
      post articles_path, :article => {:title => 'My article'}, :authenticity_token => 'INVALID'
    end

    # assert we are signed out, both at session level and cookie level.
    assert cookies['remember_me'].blank?
    get_via_redirect new_article_path
    assert_equal sign_in_path, path
  end
end
