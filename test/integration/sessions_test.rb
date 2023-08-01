require 'test_helper'

# sqlite: primary key needs AUTOINCREMENT to not reuse previous values
# https://www.sqlite.org/faq.html#q1
# AR should do this by default (but it seems sometimes doesn't)

class SessionsTest < IntegrationTest

  setup do
    User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    QuoVadis.session_lifetime :session
    QuoVadis.two_factor_authentication_mandatory false
  end


  test 'sessions require authentication' do
    get quo_vadis.sessions_path
    assert_redirected_to quo_vadis.login_path
  end


  test "user's sessions are independent" do
    desktop = login
    phone = login

    refute_equal jar(desktop).encrypted[QuoVadis.cookie_name],
                 jar(phone).encrypted[QuoVadis.cookie_name]
  end


  test 'user can logout without logging out another session' do
    desktop = login
    phone = login

    # logout on phone
    phone.delete quo_vadis.logout_path

    # assert phone logged out
    phone.assert_response :redirect
    assert_equal 'You have logged out.', phone.flash[:notice]
    refute jar(phone).encrypted[QuoVadis.cookie_name]
    refute phone.controller.logged_in?

    # assert desktop still logged in
    assert jar(desktop).encrypted[QuoVadis.cookie_name]
  end


  test "user can log out a separate session" do
    desktop = login
    phone = login

    # on phone, list sessions
    phone.get quo_vadis.sessions_path
    phone.assert_response :success
    phone.assert_select 'td', 'This session'
    phone.assert_select 'td button[type=submit]', text: 'Log out', count: 1

    # on phone, log out the desktop session
    phone.delete quo_vadis.session_path(QuoVadis::Session.first.id)
    phone.assert_redirected_to quo_vadis.sessions_path

    # phone is still logged in
    assert_equal 'You have logged out of the other session.', phone.flash[:notice]

    # desktop is logged out
    desktop.get '/articles'
    refute desktop.controller.logged_in?
  end


  test 'non-authentication session data is not removed on logout' do
    desktop = login
    session_id = desktop.session.id

    desktop.get secret_articles_path
    assert_equal 'bar', desktop.session[:foo]

    desktop.delete quo_vadis.logout_path
    refute desktop.controller.logged_in?

    desktop.get articles_path
    assert_equal 'bar', desktop.session[:foo]
    refute_equal session_id, desktop.session.id
  end


  private

  # starts a new rails session and logs in
  def login
    open_session do |sess|
      sess.post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
    end
  end

  # logs in in current session
  def plain_login
    post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
  end

end
