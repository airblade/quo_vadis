require 'test_helper'

class PasswordResetTest < IntegrationTest

  setup do
    @user = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
  end


  test 'new password reset' do
    get quo_vadis.new_password_reset_path
    assert_response :success
  end


  test 'unknown identifier' do
    post quo_vadis.password_resets_path(email: 'foo@example.com')
    assert_response :success
    assert_equal 'A link to change your password has been emailed to you.', flash[:notice]
  end


  test 'known identifier' do
    assert_emails 1 do
      post quo_vadis.password_resets_path(email: 'bob@example.com')
    end
    assert_redirected_to quo_vadis.password_resets_path
    assert_equal 'A link to change your password has been emailed to you.', flash[:notice]
  end


  test 'click link in email' do
    assert_emails 1 do
      post quo_vadis.password_resets_path(email: 'bob@example.com')
    end
    get extract_url_from_email
    assert_response :success
  end


  test 'expired link' do
    assert_emails 1 do
      post quo_vadis.password_resets_path(email: 'bob@example.com')
    end
    travel QuoVadis.password_reset_token_lifetime + 1.minute
    get extract_url_from_email
    assert_redirected_to quo_vadis.new_password_reset_path
    assert_equal 'Either the link has expired or you have already reset your password.', flash[:alert]
  end


  test 'link cannot be reused' do
    assert_emails 1 do
      post quo_vadis.password_resets_path(email: 'bob@example.com')
    end
    put quo_vadis.password_reset_path(extract_token_from_email, password: 'xxxxxxxxxxxx', password_confirmation: 'xxxxxxxxxxxx')
    assert controller.logged_in?

    get quo_vadis.edit_password_reset_url(extract_token_from_email)
    assert_redirected_to quo_vadis.new_password_reset_path
    assert_equal 'Either the link has expired or you have already reset your password.', flash[:alert]
  end


  test 'new password invalid' do
    digest = @user.qv_account.password.password_digest

    assert_emails 1 do
      post quo_vadis.password_resets_path(email: 'bob@example.com')
    end

    assert_no_difference 'QuoVadis::Session.count' do
      put quo_vadis.password_reset_path(extract_token_from_email, password: '', password_confirmation: '')
    end

    assert_equal digest, @user.qv_account.password.reload.password_digest
    assert_response :success
    assert_equal quo_vadis.password_reset_path(extract_token_from_email), path
  end


  test 'new password valid' do
    QuoVadis.two_factor_authentication_mandatory false

    digest = @user.qv_account.password.password_digest

    desktop = session_login
    phone = session_login

    get articles_url
    refute controller.logged_in?

    assert_emails 1 do
      post quo_vadis.password_resets_path(email: 'bob@example.com')
    end

    assert_difference 'QuoVadis::Session.count', (- 2 + 1) do
      put quo_vadis.password_reset_path(extract_token_from_email, password: 'xxxxxxxxxxxx', password_confirmation: 'xxxxxxxxxxxx')
    end

    assert controller.logged_in?

    desktop.get articles_url
    refute desktop.controller.logged_in?  # NOTE: flaky; if this fails, re-migrate the database.

    phone.get articles_url
    refute phone.controller.logged_in?

    refute_equal digest, @user.qv_account.password.reload.password_digest

    assert_redirected_to '/articles/secret'
    assert_equal 'Your password has been changed and you are logged in.', flash[:notice]
  end


  private

  def session_login
    open_session do |sess|
      sess.post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
    end
  end

  def extract_url_from_email
    ActionMailer::Base.deliveries.last.decoded[%r{^http://.*$}, 0]
  end

  def extract_path_from_email
    extract_url_from_email.sub 'http://www.example.com', ''
  end

  def extract_token_from_email
    extract_url_from_email[%r{/([^/]*)$}, 1]
  end

end
