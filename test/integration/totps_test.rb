require 'test_helper'

class TotpsTest < IntegrationTest

  setup do
    User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    QuoVadis.two_factor_authentication_mandatory true
    login
  end


  test ':challenge redirects to :new when no second factor setup' do
    get quo_vadis.challenge_totps_path
    assert_redirected_to quo_vadis.new_totp_path
    assert_equal 'Please set up two factor authentication.', flash[:alert]
  end


  test 'set up second factor' do
    get quo_vadis.new_totp_path
    assert_response :success

    totp = controller.instance_variable_get :@totp
    assert_emails 1 do
      assert_difference 'QuoVadis::RecoveryCode.count', 5 do
        assert_difference 'QuoVadis::Totp.count' do
          post quo_vadis.totps_path(totp: {
            key: totp.key,
            hmac_key: totp.hmac_key,
            otp: ROTP::TOTP.new(totp.key).now
          })
        end
      end
    end

    assert_redirected_to quo_vadis.recovery_codes_path
  end


  test 'does not set up second factor when key tampered with' do
    get quo_vadis.new_totp_path

    totp = controller.instance_variable_get :@totp
    assert_no_difference 'QuoVadis::Totp.count' do
      post quo_vadis.totps_path(totp: {
        key: 'dodgy',
        hmac_key: totp.hmac_key,
        otp: ROTP::TOTP.new('dodgy').now
      })
    end

    assert_equal 'Sorry, the code was incorrect. Please check your system clock is correct and try again.', flash[:alert]
    assert_redirected_to quo_vadis.new_totp_path
  end


  test 'authenticate with second factor' do
    totp = User.last.qv_account.create_totp(last_used_at: 1.minute.ago)

    get quo_vadis.challenge_totps_path
    assert_response :success

    assert_session_replaced do
      post quo_vadis.authenticate_totps_path(totp: ROTP::TOTP.new(totp.key).now)
    end
    assert QuoVadis::Session.last.second_factor_authenticated?
    assert_equal 'Welcome back!', flash[:notice]
    assert_redirected_to '/articles/secret'
  end


  test 'failed authentication with second factor' do
    User.last.qv_account.create_totp(last_used_at: 1.minute.ago)

    post quo_vadis.authenticate_totps_path(totp: '123456')
    refute QuoVadis::Session.last.second_factor_authenticated?
    assert_response :unprocessable_entity
    assert_equal 'Sorry, the code was incorrect. Please check your system clock is correct and try again.', flash[:alert]
  end


  test '2fa code reused' do
    totp = User.last.qv_account.create_totp(last_used_at: 1.minute.ago)
    post quo_vadis.authenticate_totps_path(totp: ROTP::TOTP.new(totp.key).now)
    assert_emails 1 do
      post quo_vadis.authenticate_totps_path(totp: ROTP::TOTP.new(totp.key).now)
    end
  end


  private

  def login
    post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
  end
end
