require 'test_helper'

class TotpTest < ActiveSupport::TestCase

  test 'key changes for each new object' do
    totp = QuoVadis::Totp.new
    refute_empty totp.key

    totp2 = QuoVadis::Totp.new
    refute_empty totp2.key

    refute_equal totp.key, totp2.key
  end


  test 'key is encrypted in database' do
    user = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    totp = user.qv_account.create_totp last_used_at: 1.minute.ago
    refute_equal totp.key, totp.read_attribute_before_type_cast(:key)
  end


  test 'validates provided hmac' do
    totp = QuoVadis::Totp.new account: QuoVadis::Account.new
    hmac = totp.hmac_key
    assert totp.valid?

    totp.provided_hmac_key = 'wrong'
    refute totp.valid?
    refute_empty totp.errors[:key]

    totp.provided_hmac_key = hmac
    assert totp.valid?
  end


  test 'verify' do
    user = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'

    qv_totp = QuoVadis::Totp.new account: user.qv_account
    totp = ROTP::TOTP.new qv_totp.key

    otp = totp.now

    assert qv_totp.verify otp  # one time
    refute qv_totp.verify otp

    travel 30.seconds
    otp2 = totp.now
    refute_equal otp, otp2
    assert qv_totp.verify otp2
  end


  test 'reused?' do
    user = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'

    qv_totp = QuoVadis::Totp.new account: user.qv_account
    totp = ROTP::TOTP.new qv_totp.key

    otp = totp.now

    assert qv_totp.verify otp  # one time
    refute qv_totp.verify otp
    assert qv_totp.reused? otp
  end

end
