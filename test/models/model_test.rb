require 'test_helper'

class ModelTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'responds to' do
    assert_respond_to User, :authenticates
    u = User.new
    assert_respond_to u, :password
    assert_respond_to u, :password=
    assert_respond_to u, :password_confirmation
    assert_respond_to u, :password_confirmation=
  end


  test 'creates account' do
    u = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    assert u.persisted?
    assert u.qv_account.persisted?
  end


  test 'destroys account' do
    u = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    ac = u.qv_account
    u.destroy
    assert ac.destroyed?
  end


  test 'copies model identifier to account' do
    email = 'bob@example.com'
    u = User.create! name: 'bob', email: email, password: '123456789abc'
    assert_equal email, u.qv_account.identifier

    email = 'b@foo.com'
    u.update email: email
    u.qv_account.reload
    assert_equal email, u.qv_account.identifier

    u.update name: nil, email: 'xyz'  # nil name is invalid
    u.qv_account.reload
    refute_equal 'xyz', u.qv_account.identifier
  end


  test 'ensures uniqueness validation on identifier' do
    Foo = Class.new ActiveRecord::Base
    assert_raises NotImplementedError, 'missing uniqueness validation on ModelTest::Foo#email.  Try adding: `validates :email, uniqueness: true`' do
      Foo.instance_eval 'authenticates'
    end

    Bar = Class.new ActiveRecord::Base
    Bar.instance_eval 'validates :email, uniqueness: true'
    Bar.instance_eval 'authenticates'
    # no error raised
  end


  test 'notifies on email change' do
    freeze_time
    u = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    assert_enqueued_email_with QuoVadis::Mailer,
      :email_change_notification,
      args: {email: 'bob@example.com', ip: nil, timestamp: Time.now} do
      u.update email: 'robert@example.com'
    end
  end
end
