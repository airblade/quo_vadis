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
    p = Person.create! username: 'bob', email: 'bob@example.com', password: 'secretsecret'
    assert_enqueued_email_with QuoVadis::Mailer, :identifier_change_notification, args: {email: 'bob@example.com', identifier: 'username'} do
      assert_enqueued_emails 1 do
        p.update username: 'robert@example.com'
      end
    end
  end


  test 'does not notify on identifier change when notifier is email' do
    u = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    assert_enqueued_email_with QuoVadis::Mailer, :email_change_notification, args: {email: 'bob@example.com'} do
      assert_enqueued_emails 1 do
        u.update email: 'robert@example.com'
      end
    end
  end

end
