require 'test_helper'

class PasswordTest < ActiveSupport::TestCase

  VALID_PASSWORD = '123456789abc'
  SIXTY_FOUR_CHARS = '1234567890123456789012345678901234567890123456789012345678901234'

  test 'validations' do
    pw = QuoVadis::Password.new
    pw.valid?
    refute_empty pw.errors[:password]

    pw.password = nil
    pw.valid?
    refute_empty pw.errors[:password]

    pw.password = ''
    pw.valid?
    refute_empty pw.errors[:password]

    pw.password = 'x'
    pw.valid?
    refute_empty pw.errors[:password]

    pw.password = VALID_PASSWORD
    pw.valid?
    assert_empty pw.errors[:password]
  end


  test 'confirmation' do
    pw = QuoVadis::Password.new password: VALID_PASSWORD, password_confirmation: nil
    pw.valid?
    assert_empty pw.errors[:password_confirmation]

    pw = QuoVadis::Password.new password: VALID_PASSWORD, password_confirmation: ''
    pw.valid?
    refute_empty pw.errors[:password_confirmation]

    pw.password_confirmation = VALID_PASSWORD
    pw.valid?
    assert_empty pw.errors[:password_confirmation]
    assert_empty pw.errors[:password]
  end


  test 'model passes through password to quo_vadis' do
    user = User.new name: 'bob', email: 'bob@example.com'
    assert user.valid?

    user = User.new name: 'bob', email: 'bob@example.com', password: ''
    refute user.valid?
    refute_empty user.errors[:password]

    user.password = 'x'
    refute user.valid?
    refute_empty user.errors[:password]

    user.password = VALID_PASSWORD
    assert user.save

    _user = User.last
    assert _user.valid?

    _pw = _user.qv_account.password
    assert _pw.valid?
  end


  test 'model passes through password confirmation to quo_vadis' do
    user = User.new name: 'bob', email: 'bob@example.com', password: VALID_PASSWORD, password_confirmation: 'x'
    refute user.valid?
    refute_empty user.errors[:password_confirmation]

    user.password_confirmation = VALID_PASSWORD
    assert user.valid?
  end


  test 'change' do
    user = User.create! name: 'bob', email: 'bob@example.com', password: VALID_PASSWORD
    pw = user.qv_account.password

    refute pw.change('wrong', '', '')
    assert_equal ['is incorrect'], pw.errors[:password]

    pw = QuoVadis::Password.find pw.id
    refute pw.change(VALID_PASSWORD, '', '')
    assert_equal ["can't be blank"], pw.errors[:new_password]

    pw = QuoVadis::Password.find pw.id
    refute pw.change(VALID_PASSWORD, 'x', 'x')
    assert_equal ["is too short (minimum is #{QuoVadis.password_minimum_length} characters)"], pw.errors[:new_password]

    pw = QuoVadis::Password.find pw.id
    refute pw.change(VALID_PASSWORD, 'xxxxxxxxxxxx', 'yyyyyyyyyyyy')
    assert_equal ["doesn't match Password"], pw.errors[:new_password_confirmation]

    pw = QuoVadis::Password.find pw.id
    assert pw.change(VALID_PASSWORD, 'xxxxxxxxxxxx', 'xxxxxxxxxxxx')
    assert pw.authenticate 'xxxxxxxxxxxx'
  end


  test 'reset' do
    user = User.create! name: 'bob', email: 'bob@example.com', password: VALID_PASSWORD
    pw = user.qv_account.password

    refute pw.reset('', '')
    assert_equal ["can't be blank"], pw.errors[:password]

    refute pw.reset('x', 'x')
    assert_equal ["is too short (minimum is #{QuoVadis.password_minimum_length} characters)"], pw.errors[:password]

    refute pw.reset('xxxxxxxxxxxx', 'yyyyyyyyyyyy')
    assert_equal ["doesn't match Password"], pw.errors[:password_confirmation]

    assert pw.reset('xxxxxxxxxxxx', 'xxxxxxxxxxxx')
    assert pw.authenticate 'xxxxxxxxxxxx'
  end


  test 'cascade destroy' do
    user = User.create! name: 'bob', email: 'bob@example.com', password: VALID_PASSWORD
    assert user.qv_account.persisted?
    assert user.qv_account.password.persisted?

    user.destroy
    assert user.qv_account.destroyed?
    assert user.qv_account.password.destroyed?
  end


  test 'cannot override existing password' do
    user = User.create! name: 'bob', email: 'bob@example.com', password: VALID_PASSWORD

    assert_raises QuoVadis::PasswordExistsError do
      user.password = 'cba987654321'
    end
  end


  test 'passwords may be 64 characters or longer' do
    pw = QuoVadis::Password.new password: SIXTY_FOUR_CHARS
    pw.valid?
    assert_empty pw.errors[:password]

    pw.password = "#{SIXTY_FOUR_CHARS}abc"
    pw.valid?
    assert_empty pw.errors[:password]
  end

  test 'passwords may contain spaces, no truncation' do
    pw = QuoVadis::Password.new password: '            '
    pw.valid?
    assert_empty pw.errors[:password]
  end

  test 'passwords may contain unicode characters' do
    pw = QuoVadis::Password.new password: '★ ★ ★ ★ ★ ★ '
    pw.valid?
    assert_empty pw.errors[:password]
  end


end
