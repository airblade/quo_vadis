require 'test_helper'

class PasswordChangeTest < IntegrationTest

  setup do
    QuoVadis.two_factor_authentication_mandatory false
    User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    login
  end


  test 'requires login' do
    logout

    put quo_vadis.password_path
    assert_redirected_to quo_vadis.login_path
  end


  test 'incorrect password' do
    put quo_vadis.password_path(password: 'x')
    assert_response :unprocessable_entity
    assert_equal ['is incorrect'], password_instance.errors[:password]
  end


  test 'new password empty' do
    put quo_vadis.password_path(password: '123456789abc', new_password: '')
    assert_response :unprocessable_entity
    assert_equal ["can't be blank"], password_instance.errors[:new_password]
  end


  test 'new password too short' do
    put quo_vadis.password_path(password: '123456789abc', new_password: 'x')
    assert_response :unprocessable_entity
    assert_equal ["is too short (minimum is #{QuoVadis.password_minimum_length} characters)"], password_instance.errors[:new_password]
  end


  test 'new password confirmation does not match' do
    put quo_vadis.password_path(password: '123456789abc', new_password: 'xxxxxxxxxxxx', new_password_confirmation: 'y')
    assert_response :unprocessable_entity
    assert_equal ["doesn't match Password"], password_instance.errors[:new_password_confirmation]
  end


  test 'success' do
    assert_emails 1 do
      assert_session_replaced do
        put quo_vadis.password_path(password: '123456789abc', new_password: 'xxxxxxxxxxxx', new_password_confirmation: 'xxxxxxxxxxxx')
        assert_response :redirect
        assert_equal 'Your password has been changed.', flash[:notice]
      end
    end
  end


  test 'logs out other sessions' do
    desktop = session_login
    phone = session_login

    desktop.put quo_vadis.password_path(password: '123456789abc', new_password: 'xxxxxxxxxxxx', new_password_confirmation: 'xxxxxxxxxxxx')
    desktop.follow_redirect!
    assert desktop.controller.logged_in?

    phone.get articles_path
    refute phone.controller.logged_in?
  end


  private

  # starts a new rails session and logs in
  def session_login
    open_session do |sess|
      sess.post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
    end
  end

  def login
    post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
  end

  def logout
    delete quo_vadis.logout_path
  end

  def password_instance
    controller.instance_variable_get :@password
  end

end
