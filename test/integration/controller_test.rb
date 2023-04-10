require 'test_helper'

class ControllerTest < IntegrationTest

  setup do
    User.first_or_create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    QuoVadis.two_factor_authentication_mandatory false
  end


  teardown do
    QuoVadis.session_lifetime_extend_to_end_of_day false
    QuoVadis.session_idle_timeout :lifetime
  end


  test 'require_authentication when not logged in' do
    get secret_articles_path

    assert_redirected_to quo_vadis.login_path
    assert_equal 'Please log in first.', flash[:notice]
  end


  test 'require_authentication when logged in' do
    login
    get secret_articles_path

    assert_response :success
    assert_equal secret_articles_path, path
  end


  test 'require_authentication remembers original path' do
    get also_secret_articles_path
    assert_equal '/articles/also_secret', session[:qv_bookmark]
  end


  test 'require_two_factor_authentication when not logged in' do
    QuoVadis.two_factor_authentication_mandatory true
    get very_secret_articles_path

    assert_redirected_to quo_vadis.login_path
    assert_equal 'Please log in first.', flash[:notice]
  end


  test 'require_two_factor_authentication when logged in but second factor not required' do
    QuoVadis.two_factor_authentication_mandatory false
    login
    get very_secret_articles_path

    assert_response :success
    assert_equal very_secret_articles_path, path
  end


  test 'require_two_factor_authentication when logged in and second factor required' do
    QuoVadis.two_factor_authentication_mandatory true
    login
    get very_secret_articles_path

    assert_redirected_to quo_vadis.challenge_totps_path
    follow_redirect!

    # This second redirect is part of the totps controller but I think
    # it makes sense to test here.
    assert_redirected_to quo_vadis.new_totp_path
    assert_equal 'Please set up two factor authentication.', flash[:alert]
  end


  test 'require_two_factor_authentication when already authenticated with two factors' do
    User.first.qv_account.create_totp! last_used_at: Time.now
    QuoVadis.two_factor_authentication_mandatory true
    login
    QuoVadis::Session.last.authenticated_with_second_factor

    get very_secret_articles_path
    assert_equal very_secret_articles_path, path
  end


  test 'second_factor_required?' do
    # 2FA optional, user has not set up 2nd factor
    QuoVadis.two_factor_authentication_mandatory false
    login
    get articles_path
    assert controller.logged_in?
    refute controller.qv.second_factor_required?

    # 2FA optional, user has set up 2nd factor
    QuoVadis.two_factor_authentication_mandatory false
    User.first.qv_account.create_totp! last_used_at: Time.now
    login
    get articles_path
    assert controller.logged_in?
    assert controller.qv.second_factor_required?

    # 2FA mandatory
    QuoVadis.two_factor_authentication_mandatory true
    login
    get articles_path
    assert controller.logged_in?
    assert controller.qv.second_factor_required?
  end


  test 'logged_in?' do
    # not logged in
    get articles_path
    refute @controller.logged_in?

    # logged in
    login
    get articles_path
    assert @controller.logged_in?

    # session remotely deleted
    QuoVadis::Session.destroy jar.encrypted[QuoVadis.cookie_name]
    get articles_path
    refute @controller.logged_in?

    # login and logout
    login
    get articles_path
    logout
    refute @controller.logged_in?
  end


  test 'login' do
    QuoVadis.two_factor_authentication_mandatory false

    get articles_path
    session_id = session.id
    assert_nil jar.encrypted[QuoVadis.cookie_name]

    assert_difference 'QuoVadis::Session.count' do
      # We want to test the controller mixin's login method, not the session
      # controller's login action, i.e. the following:
      #
      #     @controller.login user
      #
      # But we store the QuoVadis session id in an encrypted cookie, and we can
      # only access cookies as part of a request-response cycle.  So we have to
      # trigger the mixin's login method via the session controller's login action.
      login
    end

    refute_equal session_id, session.id
    qv_session = QuoVadis::Session.last
    assert_equal qv_session.id, jar.encrypted[QuoVadis.cookie_name]
  end


  test 'logout' do
    login

    session_id = session.id
    qv_session_id = jar.encrypted[QuoVadis.cookie_name]
    assert QuoVadis::Session.exists?(qv_session_id)

    assert_difference 'QuoVadis::Session.count', -1 do
      # We want to test the controller mixin's logout method, not the session
      # controller's logout action, i.e. the following:
      #
      #     @controller.logout
      #
      # But we store the QuoVadis session id in an encrypted cookie, and we can
      # only access cookies as part of a request-response cycle.  So we have to
      # trigger the mixin's logout method via the session controller's logout action.
      logout
    end

    refute_equal session_id, session.id
    assert_nil jar.encrypted[QuoVadis.cookie_name]
    refute QuoVadis::Session.exists?(qv_session_id)
  end


  test 'qv_logout_other_sessions' do
    desktop = session_login
    phone = session_login

    desktop.controller.qv.logout_other_sessions

    phone.get articles_path
    refute phone.controller.logged_in?

    desktop.get articles_path
    assert desktop.controller.logged_in?
  end


  test 'authenticated_model' do
    # not logged in
    get articles_path
    assert_nil @controller.authenticated_model

    # logged in
    login
    get articles_path
    assert_equal User.first, @controller.authenticated_model
  end


  # test 'request_confirmation' do
  #   get articles_path

  #   assert_emails 1 do
  #     controller.request_confirmation User.last
  #   end
  #   assert_equal 'A link to confirm your account has been emailed to you.', flash[:notice]
  # end


  test 'session lifetime exceeded' do
    QuoVadis.session_lifetime 1.week
    login

    travel 1.week
    travel (-5).minutes
    get articles_path
    assert controller.logged_in?

    travel 10.minutes
    get articles_path
    refute controller.logged_in?
  end


  test 'session lifetime extended to end of day' do
    QuoVadis.session_lifetime 1.week
    QuoVadis.session_lifetime_extend_to_end_of_day true
    login

    travel 1.week
    travel 10.minutes
    get articles_path
    assert controller.logged_in?

    travel 1.day
    get articles_path
    refute controller.logged_in?
  end


  test 'idle timeout exceeded' do
    QuoVadis.session_lifetime 1.week
    QuoVadis.session_idle_timeout 1.day
    login

    get articles_path
    assert controller.logged_in?

    travel 2.days

    get articles_path
    refute controller.logged_in?
  end


  private

  def login
    post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
  end

  def logout
    delete quo_vadis.logout_path
  end

  def session_login
    open_session do |sess|
      sess.post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
    end
  end
end
