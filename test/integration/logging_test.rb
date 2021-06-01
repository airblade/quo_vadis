require 'test_helper'

class LoggingTest < IntegrationTest

  setup do
    user = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    @account = user.qv_account
  end


  test 'logs endpoint' do
    QuoVadis::Log.create account: @account, action: 'password.change', ip: '1.2.3.4', metadata: {foo: 'bar', baz: 'qux'}
    login
    get quo_vadis.logs_path
    assert_response :success

    assert_select 'tbody tr' do
      assert_select 'td', 'password.change'
      assert_select 'td', '1.2.3.4'
      assert_select 'td', 'foo: bar, baz: qux'
    end

    assert_select 'tbody tr' do
      assert_select 'td', 'login.success'
      assert_select 'td', '127.0.0.1'
      assert_select 'td', ''
    end
  end


  test 'login.success' do
    assert_log QuoVadis::Log::LOGIN_SUCCESS do
      login
    end
  end


  test 'login.failure' do
    assert_log QuoVadis::Log::LOGIN_FAILURE do
      post quo_vadis.login_path(email: 'bob@example.com', password: 'wrong')
    end
  end


  test 'login.unknown' do
    assert_log QuoVadis::Log::LOGIN_UNKNOWN, {'identifier' => 'wrong'}, nil do
      post quo_vadis.login_path(email: 'wrong', password: 'wrong')
    end
  end


  test 'totp.setup' do
    login
    get quo_vadis.new_totp_path
    totp = controller.instance_variable_get :@totp
    assert_log QuoVadis::Log::TOTP_SETUP do
      post quo_vadis.totps_path(totp: {
        key: totp.key,
        hmac_key: totp.hmac_key,
        otp: ROTP::TOTP.new(totp.key).now
      })
    end
  end


  test 'totp.success' do
    login
    totp = User.last.qv_account.create_totp(last_used_at: 1.minute.ago)
    assert_log QuoVadis::Log::TOTP_SUCCESS do
      post quo_vadis.authenticate_totps_path(totp: ROTP::TOTP.new(totp.key).now)
    end
  end


  test 'totp.failure' do
    login
    User.last.qv_account.create_totp(last_used_at: 1.minute.ago)
    assert_log QuoVadis::Log::TOTP_FAILURE do
      post quo_vadis.authenticate_totps_path(totp: '000000')
    end
  end


  test 'totp.reuse' do
    login
    totp = User.last.qv_account.create_totp(last_used_at: 1.minute.ago)
    post quo_vadis.authenticate_totps_path(totp: ROTP::TOTP.new(totp.key).now)
    assert_log QuoVadis::Log::TOTP_REUSE do
      post quo_vadis.authenticate_totps_path(totp: ROTP::TOTP.new(totp.key).now)
    end
  end


  test 'recovery_code.success' do
    login
    codes = @account.generate_recovery_codes
    assert_log QuoVadis::Log::RECOVERY_CODE_SUCCESS do
      post quo_vadis.authenticate_recovery_codes_path(code: codes.first)
    end
  end


  test 'recovery_code.failure' do
    login
    assert_log QuoVadis::Log::RECOVERY_CODE_FAILURE do
      post quo_vadis.authenticate_recovery_codes_path(code: 'nope')
    end
  end


  test 'recovery_code.generate' do
    login
    assert_log QuoVadis::Log::RECOVERY_CODE_GENERATE do
      post quo_vadis.generate_recovery_codes_path
    end
  end


  test '2fa.deactivated' do
    login
    assert_log QuoVadis::Log::TWOFA_DEACTIVATED do
      delete quo_vadis.twofa_path
    end
  end


  test 'identifier.change on account' do
    assert_log QuoVadis::Log::IDENTIFIER_CHANGE, {'from' => 'bob@example.com', 'to' => 'x'} do
      QuoVadis::CurrentRequestDetails.set(ip: '127.0.0.1') do
        @account.update identifier: 'x'
      end
    end
  end


  test 'email.change aka identifier.change on model' do
    # In our setup the identifier is the email so we expect changing the
    # email to change the identifier too.
    assert_difference 'QuoVadis::Log.count', 2 do
      QuoVadis::CurrentRequestDetails.set(ip: '127.0.0.1') do
        @account.model.update email: 'x'
      end
    end
    log = QuoVadis::Log.first
    assert_equal @account, log.account
    assert_equal QuoVadis::Log::IDENTIFIER_CHANGE, log.action
    assert_equal '127.0.0.1', log.ip
    assert_equal({'from' => 'bob@example.com', 'to' => 'x'}, log.metadata)
    log = QuoVadis::Log.last
    assert_equal @account, log.account
    assert_equal QuoVadis::Log::EMAIL_CHANGE, log.action
    assert_equal '127.0.0.1', log.ip
    assert_equal({'from' => 'bob@example.com', 'to' => 'x'}, log.metadata)
  end


  test 'password.change' do
    login
    assert_log QuoVadis::Log::PASSWORD_CHANGE do
      put quo_vadis.password_path(password: '123456789abc', new_password: 'xxxxxxxxxxxx', new_password_confirmation: 'xxxxxxxxxxxx')
    end
  end


  test 'password.reset' do
    assert_difference 'QuoVadis::Log.count', 2 do
      token = QuoVadis::PasswordResetToken.generate @account
      put quo_vadis.password_reset_path(token, password: {password: 'xxxxxxxxxxxx', password_confirmation: 'xxxxxxxxxxxx'})
    end
    assert_equal QuoVadis::Log::PASSWORD_RESET, QuoVadis::Log.first.action
    assert_equal QuoVadis::Log::LOGIN_SUCCESS, log.action
  end


  test 'account.confirmation' do
    assert_difference 'QuoVadis::Log.count', 2 do
      token = QuoVadis::AccountConfirmationToken.generate @account
      put quo_vadis.confirmation_path(token)
    end
    assert_equal QuoVadis::Log::ACCOUNT_CONFIRMATION, QuoVadis::Log.first.action
    assert_equal QuoVadis::Log::LOGIN_SUCCESS, log.action
  end


  test 'logout.other' do
    login_new_session
    phone = login_new_session

    # logout first session from phone
    assert_log QuoVadis::Log::LOGOUT_OTHER do
      phone.delete quo_vadis.session_path(QuoVadis::Session.first.id)
    end
  end


  test 'logout' do
    post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
    assert_log QuoVadis::Log::LOGOUT do
      delete quo_vadis.logout_path
    end
  end


  private

  def assert_log(action, metadata = {}, account = @account, &block)
    assert_difference 'QuoVadis::Log.count' do
      yield
    end

    if account.nil?
      assert_nil log.account
    else
      assert_equal account, log.account
    end
    assert_equal action, log.action
    assert_equal '127.0.0.1', log.ip
    assert_equal metadata, log.metadata
  end

  def log
    QuoVadis::Log.last
  end

  def login
    post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
  end

  def login_new_session
    open_session do |sess|
      sess.post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
    end
  end

end
