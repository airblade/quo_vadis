require 'test_helper'

class LogTest < ActiveSupport::TestCase

  test 'smoke' do
    user = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    account = user.qv_account

    log = account.logs.create! action: QuoVadis::Log::LOGIN_SUCCESS, ip: '1.2.3.4', metadata: {foo: 'bar'}

    assert_equal QuoVadis::Log::LOGIN_SUCCESS, log.action
    assert_equal '1.2.3.4', log.ip
    assert_equal 'bar', log.metadata['foo']
  end

end
