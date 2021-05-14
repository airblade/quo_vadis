require 'test_helper'

class TwofaTest < IntegrationTest

  setup do
    u = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    @account = u.qv_account
    QuoVadis.two_factor_authentication_mandatory true
    # @codes = u.qv_account.generate_recovery_codes
    login
  end


  test 'no totp, no recovery codes' do
    get quo_vadis.twofa_path
    assert_response :success
    assert_select "a[href=?]", quo_vadis.new_totp_path
    assert_select "a[href=?]", quo_vadis.recovery_codes_path
  end


  test 'totp, no recovery codes' do
    setup_totp
    get quo_vadis.twofa_path
    assert_select 'form[action=?]', quo_vadis.twofa_path do
      assert_select 'input[value=delete]'
    end
    assert_select "a[href=?]", quo_vadis.recovery_codes_path
  end


  test 'no totp, recovery codes' do
    setup_recovery_codes
    get quo_vadis.twofa_path
    assert_select "a[href=?]", quo_vadis.new_totp_path
    assert_select "a[href=?]", quo_vadis.recovery_codes_path
  end


  test 'totp, recovery codes' do
    setup_totp
    setup_recovery_codes
    get quo_vadis.twofa_path
    assert_select 'form[action=?]', quo_vadis.twofa_path do
      assert_select 'input[value=delete]'
    end
    assert_select "a[href=?]", quo_vadis.recovery_codes_path
  end


  test 'deactivate' do
    setup_totp
    setup_recovery_codes

    assert_emails 1 do
      delete quo_vadis.twofa_path
    end

    # The flash only seems to be set before the redirect.  No idea why.
    assert_equal 'You have invalidated your 2FA credentials and recovery codes.', flash[:notice]
    @account.reload
    assert_nil @account.totp
    assert_empty @account.recovery_codes
    @account.sessions.each { |s| refute s.second_factor_authenticated? }
    assert_redirected_to quo_vadis.twofa_path
  end


  private

  def login
    post quo_vadis.login_path(email: 'bob@example.com', password: '123456789abc')
  end

  def setup_totp
    @account.create_totp last_used_at: 1.day.ago
  end

  def setup_recovery_codes
    @account.generate_recovery_codes
  end
end
