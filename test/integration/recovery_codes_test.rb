require 'test_helper'

class RecoveryCodesTest < IntegrationTest

  setup do
    u = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    u.qv_account.create_totp last_used_at: 1.day.ago
    QuoVadis.two_factor_authentication_mandatory true
    @codes = u.qv_account.generate_recovery_codes
    login
  end


  test 'use recovery code' do
    get quo_vadis.challenge_recovery_codes_path
    assert_response :success

    assert_difference 'QuoVadis::Totp.count', -1 do
      assert_difference 'QuoVadis::RecoveryCode.count', -1 do
        assert_session_replaced do
          post quo_vadis.authenticate_recovery_codes_path(code: @codes.first)
        end
      end
    end

    assert_nil User.last.qv_account.totp

    assert_redirected_to  '/articles/secret'

    # use another recovery code to verify another TOTP-reset doesn't error
    post quo_vadis.authenticate_recovery_codes_path(code: @codes[1])
  end


  test 'generate recovery codes' do
    assert_emails 1 do
      post quo_vadis.generate_recovery_codes_path
    end
    assert_redirected_to quo_vadis.recovery_codes_path
  end


  private

  def login
    post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
  end
end
