require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'confirmed?' do
    account = QuoVadis::Account.new
    refute account.confirmed?

    account.confirmed_at = Time.now
    assert account.confirmed?
  end


  test 'notifies on identifier change when notifier is not email' do
    freeze_time
    p = Person.create! username: 'bob', email: 'bob@example.com', password: 'secretsecret'
    assert_enqueued_email_with QuoVadis::Mailer,
      :identifier_change_notification,
      args: {email: 'bob@example.com', identifier: 'username', ip: nil, timestamp: Time.now} do
      assert_enqueued_emails 1 do
        p.update username: 'robert@example.com'
      end
    end
  end


  test 'does not notify on identifier change when notifier is email' do
    freeze_time
    u = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    assert_enqueued_email_with QuoVadis::Mailer,
      :email_change_notification,
      args: {email: 'bob@example.com', ip: nil, timestamp: Time.now} do
      assert_enqueued_emails 1 do
        u.update email: 'robert@example.com'
      end
    end
  end


  test 'revoke' do
    u = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    account = u.qv_account
    account.create_totp last_used_at: 1.minute.ago
    account.generate_recovery_codes

    u.revoke_authentication_credentials
    account.reload

    assert_nil account.password
    assert_nil account.totp
    assert_empty account.recovery_codes
    assert_empty account.sessions
  end

end
