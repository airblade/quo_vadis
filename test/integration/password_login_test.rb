require 'test_helper'

class PasswordLoginTest < IntegrationTest

  setup do
    QuoVadis.session_lifetime :session
  end


  test 'successful login' do
    get quo_vadis.login_path
    assert_response :success

    User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')

    assert_redirected_to secret_articles_path
    assert_equal after_login_path, secret_articles_path
  end


  test 'successful login redirects to original path' do
    get also_secret_articles_path

    User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')

    assert_redirected_to also_secret_articles_path
    assert_nil session[:qv_bookmark]
  end


  test 'failed login' do
    User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    post quo_vadis.login_path(email: 'bob@example.com', password: 'wrong')

    assert_response :success
    assert_equal quo_vadis.login_path, path
  end


  test 'unknown login' do
    post quo_vadis.login_path(email: 'bob@example.com', password: 'wrong')

    assert_response :success
    assert_equal quo_vadis.login_path, path
  end


  test 'logout' do
    User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')

    # logout
    assert jar.encrypted[QuoVadis.cookie_name]
    assert_difference 'QuoVadis::Session.count', -1 do
      delete quo_vadis.logout_path
    end
    refute jar.encrypted[QuoVadis.cookie_name]
    assert_redirected_to root_path
  end


  test 'login for browser session' do
    User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'

    open_session do |sess|
      sess.post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
      assert sess.controller.logged_in?
    end

    open_session do |sess|
      sess.get articles_path
      refute sess.controller.logged_in?
    end
  end


  # Ideally we would use multiple sessions to distinguish this from a single
  # browser session.  We would log in in one session then assert we can log in
  # in another session within the timeframe.  But I can't find a way to share
  # a cookie between test sessions (I tried nesting sessions).  So we do all
  # this within a single session, even though it has the same effect as being
  # within a single browser session.
  test 'login for 1 week' do
    QuoVadis.session_lifetime 1.week
    User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'

    post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
    refute QuoVadis::Session.last.send(:browser_session?)
    assert controller.logged_in?

    travel 5.days

    get articles_path
    assert controller.logged_in?  # flakey

    travel 3.days

    get articles_path
    refute controller.logged_in?
  end


  test 'optional remember not opted in' do
    QuoVadis.session_lifetime 1.week
    User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'

    post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc', remember: '0')
    assert QuoVadis::Session.last.send(:browser_session?)

    # Cannot test this fully without being able to share cookies between test sessions.
  end


  test 'optional remember opted in' do
    QuoVadis.session_lifetime 1.week
    User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'

    post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc', remember: '1')
    refute QuoVadis::Session.last.send(:browser_session?)

    # Cannot test this fully without being able to share cookies between test sessions.
  end
end
