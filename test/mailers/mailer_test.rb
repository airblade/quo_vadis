require 'test_helper'

class MailerTest < ActionMailer::TestCase

  tests QuoVadis::Mailer

  setup do
    QuoVadis.mail_headers({from: 'Bar <bar@example.com>'})
  end


  test 'reset_password' do
    email = QuoVadis::Mailer.with(
      email: 'Foo <foo@example.com>',
      otp: '314159'
    ).reset_password

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['foo@example.com'], email.to
    assert_equal ['bar@example.com'], email.from
    assert_equal 'Your password reset code is 314159', email.subject
    assert_equal read_fixture('reset_password.text').join, email.body.to_s
  end


  test 'account_confirmation' do
    email = QuoVadis::Mailer.with(
      email: 'Foo <foo@example.com>',
      otp: 271828
    ).account_confirmation

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['foo@example.com'], email.to
    assert_equal ['bar@example.com'], email.from
    assert_equal 'Your account confirmation code is 271828', email.subject
    assert_equal read_fixture('account_confirmation.text').join, email.body.to_s
  end


  test 'email change notification' do
    email = QuoVadis::Mailer.with(
      email: 'Foo <foo@example.com>',
      ip:        '1.2.3.4',
      timestamp: Time.now
    ).email_change_notification

    # freeze_time

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['foo@example.com'], email.to
    assert_equal ['bar@example.com'], email.from
    assert_equal 'Your email address has been changed', email.subject
    assert_equal with_timestamp(read_fixture('email_change_notification.text').join), email.body.to_s
  end


  test 'identifier change notification' do
    email = QuoVadis::Mailer.with(
      email: 'Foo <foo@example.com>',
      identifier: 'email',
      ip:        '1.2.3.4',
      timestamp: Time.now
    ).identifier_change_notification

    # freeze_time

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['foo@example.com'], email.to
    assert_equal ['bar@example.com'], email.from
    assert_equal 'Your email has been changed', email.subject
    assert_equal with_timestamp(read_fixture('identifier_change_notification.text').join), email.body.to_s
  end


  test 'password change notification' do
    email = QuoVadis::Mailer.with(
      email: 'Foo <foo@example.com>',
      ip:        '1.2.3.4',
      timestamp: Time.now
    ).password_change_notification

    # freeze_time

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['foo@example.com'], email.to
    assert_equal ['bar@example.com'], email.from
    assert_equal 'Your password has been changed', email.subject
    assert_equal with_timestamp(read_fixture('password_change_notification.text').join), email.body.to_s
  end


  test 'password reset notification' do
    email = QuoVadis::Mailer.with(
      email: 'Foo <foo@example.com>',
      ip:        '1.2.3.4',
      timestamp: Time.now
    ).password_reset_notification

    # freeze_time

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['foo@example.com'], email.to
    assert_equal ['bar@example.com'], email.from
    assert_equal 'Your password has been reset', email.subject
    assert_equal with_timestamp(read_fixture('password_reset_notification.text').join), email.body.to_s
  end


  test 'totp setup notification' do
    email = QuoVadis::Mailer.with(
      email: 'Foo <foo@example.com>',
      ip:        '1.2.3.4',
      timestamp: Time.now
    ).totp_setup_notification

    # freeze_time

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['foo@example.com'], email.to
    assert_equal ['bar@example.com'], email.from
    assert_equal 'Two-factor authentication was set up just now', email.subject
    assert_equal with_timestamp(read_fixture('totp_setup_notification.text').join), email.body.to_s
  end


  test 'totp reuse notification' do
    email = QuoVadis::Mailer.with(
      email:     'Foo <foo@example.com>',
      ip:        '1.2.3.4',
      timestamp: Time.now
    ).totp_reuse_notification

    # freeze_time

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['foo@example.com'], email.to
    assert_equal ['bar@example.com'], email.from
    assert_equal 'Your two-factor authentication code was reused just now', email.subject
    assert_equal with_timestamp(read_fixture('totp_reuse_notification.text').join), email.body.to_s
  end


  test '2fa deactivated notification' do
    email = QuoVadis::Mailer.with(
      email: 'Foo <foo@example.com>',
      ip:        '1.2.3.4',
      timestamp: Time.now
    ).twofa_deactivated_notification

    # freeze_time

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['foo@example.com'], email.to
    assert_equal ['bar@example.com'], email.from
    assert_equal 'Two-factor authentication was deactivated just now', email.subject
    assert_equal with_timestamp(read_fixture('twofa_deactivated_notification.text').join), email.body.to_s
  end


  test 'recovery codes generation notification' do
    email = QuoVadis::Mailer.with(
      email: 'Foo <foo@example.com>',
      ip:        '1.2.3.4',
      timestamp: Time.now
    ).recovery_codes_generation_notification

    # freeze_time

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ['foo@example.com'], email.to
    assert_equal ['bar@example.com'], email.from
    assert_equal 'Recovery codes have been generated for your account', email.subject
    assert_equal with_timestamp(read_fixture('recovery_codes_generation_notification.text').join), email.body.to_s
  end


  private

  def read_fixture(action)
    IO.readlines(File.join(__dir__, '..', 'fixtures', self.class.mailer_class.name.underscore, action))
  end

  def with_timestamp(str)
    str.sub 'TIMESTAMP', Time.now.strftime('%e %B at %H:%M (%Z)')
  end

end
