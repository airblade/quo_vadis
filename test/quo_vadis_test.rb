require "test_helper"

class QuoVadisTest < ActiveSupport::TestCase

  def test_that_it_has_a_version_number
    assert QuoVadis::VERSION
  end


  test 'translate' do
    assert_equal 'Welcome back!', QuoVadis.translate('flash.login.success')
    assert_equal 'You have 3 recovery codes left.', QuoVadis.translate('flash.recovery_code.success', count: 3)
    assert_nil QuoVadis.translate('does_not_exist')
  end


  test 'identifier' do
    assert_equal :email, QuoVadis.identifier('User')
  end


  test 'humanise_identifier' do
    assert_equal 'Email', QuoVadis.humanise_identifier('User')
  end


  test 'identifiers' do
    assert_equal [:username, :email], QuoVadis.send(:identifiers)
  end


  test 'detect_identifier' do
    assert_equal 'email', QuoVadis.send(:detect_identifier, ['foo', 'email', 'commit'])
  end


  test 'find_account_by_identifier_in_params' do
    u = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    assert_equal u.qv_account,
      QuoVadis.find_account_by_identifier_in_params({'foo' => 'bar', 'email' => 'bob@example.com', 'commit' => 'Save'})
  end

end
