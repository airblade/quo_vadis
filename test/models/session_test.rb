require 'test_helper'

class SessionTest < ActiveSupport::TestCase

  test 'expired?' do
    refute QuoVadis::Session.new.expired?
    assert QuoVadis::Session.new(lifetime_expires_at: 1.day.ago).expired?
    refute QuoVadis::Session.new(lifetime_expires_at: 1.day.from_now).expired?

    QuoVadis.session_idle_timeout 5.minutes
    refute QuoVadis::Session.new(lifetime_expires_at: 1.day.from_now, last_seen_at: 1.minute.ago).expired?
    assert QuoVadis::Session.new(lifetime_expires_at: 1.day.from_now, last_seen_at: 10.minutes.ago).expired?
  end


  test 'logout_other_sessions' do
    user = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    account = user.qv_account
    s0 = account.sessions.create! ip: 'ip', user_agent: 'useragent'
    s1 = account.sessions.create! ip: 'ip', user_agent: 'useragent'

    s0.logout_other_sessions

    refute s0.destroyed?
    assert s1.destroyed?
  end


  test 'reset authenticated with second factor' do
    user = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    account = user.qv_account
    session = account.sessions.create! ip: 'ip', user_agent: 'useragent'

    refute session.second_factor_authenticated?
    session.authenticated_with_second_factor
    assert session.second_factor_authenticated?
    session.reset_authenticated_with_second_factor
    refute session.second_factor_authenticated?
  end


  test 'replace' do
    user = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    account = user.qv_account

    session = account.sessions.create! ip: 'ip', user_agent: 'useragent'
    sess = session.replace

    assert_instance_of QuoVadis::Session, sess
    assert session.destroyed?
    refute_equal session.id, sess.id

    refute_includes account.sessions, session
    assert_includes account.sessions, sess

    session
      .attributes
      .reject { |name, _| %w[id created_at created_on updated_at updated_on].include? name }
      .each do |name, value|
        if value.nil?
          assert_nil sess.send(name)
        else
          assert_equal value, sess.send(name)
        end
      end
  end
end
