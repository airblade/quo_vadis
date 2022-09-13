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
    end
    refute QuoVadis::Account.last.confirmed?

    # verify response
    assert_response :redirect
    follow_redirect!
    assert_equal 'A link to confirm your account has been emailed to you.', flash[:notice]

    # click link in email
    url = extract_url_from_email
    get url
    assert_response :success
    action_path = extract_path_from_email
    assert_select "form[action='#{action_path}']"

    # click button on confirmation page
    put action_path

    # verify logged in
    assert_redirected_to '/sign_ups/confirmed'
    follow_redirect!
    assert_redirected_to '/articles/secret'
    assert_equal 'Thanks for confirming your account.  You are now logged in.', flash[:notice]
    assert controller.logged_in?
    assert QuoVadis::Account.last.confirmed?
  end


  test 'new signup updates email' do
    assert_emails 1 do
      post sign_ups_path(user: {name: 'Bob', email: 'bob@example.com', password: '123456789abc'})
    end

    get quo_vadis.edit_email_confirmations_path
    assert_response :success

    # First email: changed-email notifier sent to original address
    # Second email: confirmation email sent to new address
    assert_emails 2 do
      put quo_vadis.update_email_confirmations_path(email: 'bobby@example.com')
    end
    assert_equal ['bobby@example.com'], ActionMailer::Base.deliveries.last.to
    assert_redirected_to quo_vadis.confirmations_path
  end


  test 'resend confirmation email in same session' do
    assert_emails 1 do
      post sign_ups_path(user: {name: 'Bob', email: 'bob@example.com', password: '123456789abc'})
    end

    assert_emails 1 do
      post quo_vadis.resend_confirmations_path
    end
  end


  test 'resend confirmation email: valid identifier' do
    User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'

    get quo_vadis.new_confirmation_path
    assert_response :success

    assert_emails 1 do
      post quo_vadis.confirmations_path(email: 'bob@example.com')
    end

    assert_redirected_to  '/confirmations'
    assert_equal 'A link to confirm your account has been emailed to you.', flash[:notice]
  end


  test 'resend confirmation email: unknown identifier' do
    assert_no_emails do
      post quo_vadis.confirmations_path(email: 'bob@example.com')
    end

    assert_redirected_to quo_vadis.new_confirmation_path
    assert_equal 'Sorry, your account could not be found.  Please try again.', flash[:alert]
  end


  test 'reusing a token' do
    assert_emails 1 do
      post sign_ups_path(user: {name: 'Bob', email: 'bob@example.com', password: '123456789abc'})
    end

    put extract_path_from_email

    assert_redirected_to '/sign_ups/confirmed'
    follow_redirect!
    assert_redirected_to '/articles/secret'
    assert_equal 'Thanks for confirming your account.  You are now logged in.', flash[:notice]

    put extract_path_from_email
    assert_redirected_to quo_vadis.new_confirmation_path
    assert_equal 'Either the link has expired or your account has already been confirmed.', flash[:alert]
  end


  test 'token expired' do
    assert_emails 1 do
      post sign_ups_path(user: {name: 'Bob', email: 'bob@example.com', password: '123456789abc'})
    end

    travel QuoVadis.account_confirmation_token_lifetime + 1.minute
    get extract_url_from_email

    assert_redirected_to quo_vadis.new_confirmation_path
    assert_equal 'Either the link has expired or your account has already been confirmed.', flash[:alert]
  end


  test 'accounts requiring confirmation cannot log in' do
    User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
    assert_redirected_to quo_vadis.new_confirmation_path
    assert_equal 'Please confirm your account first.', flash[:notice]
    refute controller.logged_in?
  end


  private

  def extract_url_from_email
    ActionMailer::Base.deliveries.last.decoded[%r{^http://.*$}, 0]
  end

  def extract_path_from_email
    extract_url_from_email.sub 'http://www.example.com', ''
  end

end
