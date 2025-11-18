require 'test_helper'

class AccountConfirmationTest < IntegrationTest

  setup do
    QuoVadis.accounts_require_confirmation true
  end

  teardown do
    QuoVadis.accounts_require_confirmation false
  end


  test 'new signup requiring confirmation' do
    assert_emails 1 do
      post sign_ups_path(user: {name: 'Bob', email: 'bob@example.com', password: '123456789abc'})
      refute QuoVadis::Account.last.confirmed?
      assert controller.logged_in?

      # verify response
      assert_redirected_to '/articles/secret'
      follow_redirect!
      assert_redirected_to '/confirm'
      follow_redirect!
      assert_equal 'Please check your email for your confirmation code.', flash[:notice]
    end

    # type in confirmation code from email
    code = extract_code_from_email
    post quo_vadis.confirm_path(otp: code)

    # verify logged in
    assert_redirected_to '/articles/secret'
    assert_equal 'Thanks for confirming your account.', flash[:notice]
    assert QuoVadis::Account.last.confirmed?
  end


  test 'resend confirmation email' do
    assert_emails 1 do
      post sign_ups_path(user: {name: 'Bob', email: 'bob@example.com', password: '123456789abc'})
      assert_redirected_to '/articles/secret'
      follow_redirect!
    end

    assert_emails 1 do
      post quo_vadis.send_confirmation_path
    end
  end


  test 'cannot reuse a confirmation code' do
    assert_emails 1 do
      post sign_ups_path(user: {name: 'Bob', email: 'bob@example.com', password: '123456789abc'})
      follow_redirect!
    end

    code = extract_code_from_email
    post quo_vadis.confirm_path(otp: code)
    assert QuoVadis::Account.last.confirmed?
    assert_equal 'Thanks for confirming your account.', flash[:notice]

    post quo_vadis.confirm_path(otp: code)
    assert_equal 'You have already confirmed your account.', flash[:alert]
    assert_redirected_to '/articles/secret'
  end


  test 'confirmation code expired' do
    assert_emails 1 do
      post sign_ups_path(user: {name: 'Bob', email: 'bob@example.com', password: '123456789abc'})
      follow_redirect!
    end

    travel QuoVadis.account_confirmation_otp_lifetime + 1.minute

    code = extract_code_from_email
    post quo_vadis.confirm_path(otp: code)
    refute QuoVadis::Account.last.confirmed?
    assert_equal 'Your confirmation code has expired.  Please request another one.', flash[:alert]
    assert_redirected_to quo_vadis.confirm_path
  end


  test 'accounts requiring confirmation can log in but have to confirm' do
    User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
    assert_redirected_to '/articles/secret'
    follow_redirect!
    assert_redirected_to quo_vadis.confirm_path
    follow_redirect!
    assert controller.logged_in?
    assert_equal 'Please check your email for your confirmation code.', flash[:notice]
  end


  private

  def extract_code_from_email
    ActionMailer::Base.deliveries.last.decoded[%r{\d{6}}, 0]
  end

end
