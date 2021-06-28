require 'test_helper'

class TokenTest < ActiveSupport::TestCase

  setup do
    u = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    @account = u.qv_account
  end


  test 'account confirmation' do
    token = QuoVadis::AccountConfirmationToken.generate @account
    assert_match /^\d+-\d+--\h+$/, token
    assert_equal @account, QuoVadis::AccountConfirmationToken.find_account(token)
  end

  test 'account confirmation expired' do
    token = QuoVadis::AccountConfirmationToken.generate @account
    travel QuoVadis.account_confirmation_token_lifetime + 1.second
    assert_nil QuoVadis::AccountConfirmationToken.find_account(token)
  end

  test 'account confirmation already done' do
    token = QuoVadis::AccountConfirmationToken.generate @account
    @account.confirmed!
    assert_nil QuoVadis::AccountConfirmationToken.find_account(token)
  end

  test 'account confirmation token tampered with' do
    assert_nil QuoVadis::AccountConfirmationToken.find_account(nil)
    assert_nil QuoVadis::AccountConfirmationToken.find_account('')
    assert_nil QuoVadis::AccountConfirmationToken.find_account('asdf')

    token = QuoVadis::AccountConfirmationToken.generate @account
    id, expires_at, hash = token.match(/^(\d+)-(\d+)--(\h+)$/).captures
    fake_token = "#{id}-#{expires_at.to_i + 1}--#{hash}"
    assert_nil QuoVadis::AccountConfirmationToken.find_account(fake_token)
  end


  test 'password reset' do
    token = QuoVadis::PasswordResetToken.generate @account
    assert_match /^\d+-\d+--\h+$/, token
    assert_equal @account, QuoVadis::PasswordResetToken.find_account(token)
  end

  test 'password reset expired' do
    token = QuoVadis::PasswordResetToken.generate @account
    travel QuoVadis.password_reset_token_lifetime + 1.second
    assert_nil QuoVadis::PasswordResetToken.find_account(token)
  end

  test 'password reset already done' do
    token = QuoVadis::PasswordResetToken.generate @account
    @account.password.reset 'secretsecret', 'secretsecret'
    assert_nil QuoVadis::PasswordResetToken.find_account(token)
  end

  test 'password reset token tampered with' do
    assert_nil QuoVadis::PasswordResetToken.find_account(nil)
    assert_nil QuoVadis::PasswordResetToken.find_account('')
    assert_nil QuoVadis::PasswordResetToken.find_account('asdf')

    token = QuoVadis::PasswordResetToken.generate @account
    id, expires_at, hash = token.match(/^(\d+)-(\d+)--(\h+)$/).captures
    fake_token = "#{id}-#{expires_at.to_i + 1}--#{hash}"
    assert_nil QuoVadis::PasswordResetToken.find_account(fake_token)
  end

end
