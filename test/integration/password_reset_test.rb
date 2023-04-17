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
    post quo_vadis.password_reset_path(email: 'foo@example.com')
    assert_redirected_to quo_vadis.edit_password_reset_path
    assert_equal 'Please check your email for your reset code.', flash[:notice]
  end


  test 'known identifier' do
    assert_emails 1 do
      post quo_vadis.password_reset_path(email: 'bob@example.com')
    end
    assert_redirected_to quo_vadis.edit_password_reset_path
    assert_equal 'Please check your email for your reset code.', flash[:notice]
  end


  test 'reset code expired' do
    assert_emails 1 do
      post quo_vadis.password_reset_path(email: 'bob@example.com')
      follow_redirect!
    end

    travel QuoVadis.password_reset_otp_lifetime + 1.minute

    # type in reset code from email
    code = extract_code_from_email
    put quo_vadis.password_reset_path(password: {
      otp: code,
      password: 'secretsecret',
      password_confirmation: 'secretsecret',
    })

    assert_equal 'Your reset code has expired.  Please request another one.', flash[:alert]
    assert_redirected_to quo_vadis.new_password_reset_path
  end


  test 'reset code incorrect' do
    assert_emails 1 do
      post quo_vadis.password_reset_path(email: 'bob@example.com')
      follow_redirect!
    end

    # type in reset code from email
    put quo_vadis.password_reset_path(password: {
      otp: '000000',
      password: 'secretsecret',
      password_confirmation: 'secretsecret',
    })

    assert_redirected_to quo_vadis.new_password_reset_path
    assert_equal 'Sorry, the code was incorrect.  Please try again.', flash[:alert]
  end


  test 'new password invalid' do
    assert_emails 1 do
      post quo_vadis.password_reset_path(email: 'bob@example.com')
      follow_redirect!
    end

    # type in reset code from email
    code = extract_code_from_email
    assert_no_difference 'QuoVadis::Session.count' do
      put quo_vadis.password_reset_path(password: {
        otp: code,
        password: 'secret',
        password_confirmation: 'secret',
      })
    end

    assert_response 422
    assert_nil flash[:notice]
    refute controller.logged_in?
  end


  test 'new password valid' do
    phone = session_login
    tablet = session_login

    get articles_url
    refute controller.logged_in?

    assert_emails 1 do
      post quo_vadis.password_reset_path(email: 'bob@example.com')
      follow_redirect!
    end

    # type in reset code from email
    code = extract_code_from_email
    # deletes phone and tablet sessions and creates new session
    assert_difference 'QuoVadis::Session.count', -1 do
      put quo_vadis.password_reset_path(password: {
        otp: code,
        password: 'secretsecret',
        password_confirmation: 'secretsecret',
      })
    end

    assert_equal 'Your password has been changed and you are logged in.', flash[:notice]
    assert controller.logged_in?
    assert_redirected_to '/articles/secret'

    phone.get articles_url
    refute phone.controller.logged_in?

    tablet.get articles_url
    refute tablet.controller.logged_in?
  end


  test 'reset code cannot be reused' do
    assert_emails 1 do
      post quo_vadis.password_reset_path(email: 'bob@example.com')
      follow_redirect!
    end

    # type in reset code from email
    code = extract_code_from_email
    put quo_vadis.password_reset_path(password: {
      otp: code,
      password: 'secretsecret',
      password_confirmation: 'secretsecret',
    })

    # The password-reset process is now finished.
    # Test what happens if reset code is resubmitted with a different password.

    put quo_vadis.password_reset_path(password: {
      otp: code,
      password: 'foobarfoobar',
      password_confirmation: 'foobarfoobar',
    })

    assert_redirected_to quo_vadis.new_password_reset_path
    assert_nil flash[:alert]
    refute @user.qv_account.password.authenticate('foobarfoobar')
    assert @user.qv_account.password.authenticate('123456789abc')
  end


  private

  def session_login
    open_session do |sess|
      sess.post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
    end
  end


  def extract_code_from_email
    ActionMailer::Base.deliveries.last.decoded[%r{\d{6}}, 0]
  end

end
