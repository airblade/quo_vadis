require 'test_helper'

class RecoveryCodeTest < ActiveSupport::TestCase

  setup do
    @user = User.create! name: 'bob', email: 'bob@example.com', password: '123456789abc'
    @rc = QuoVadis::RecoveryCode.new(account: @user.qv_account).tap &:save!
  end


  test 'code can be retrieved initially' do
    assert_equal 11, @rc.code.length
  end


  test 'code does not change' do
    code = @rc.code
    @rc.valid?
    assert_equal code, @rc.code
  end


  test 'code not available after finding' do
    rc = QuoVadis::RecoveryCode.find @rc.id
    assert_nil rc.code
  end


  test 'authenticate' do
    code = @rc.code
    refute @rc.authenticate_code 'wrong'
    assert @rc.authenticate_code code
  end


  test 'recovery code is destroyed after successful use' do
    code = @rc.code
    assert @rc.authenticate_code code
    assert @rc.destroyed?
  end

  test 'generate a fresh set of codes' do
    account = @user.qv_account
    codes = []
    assert_difference 'QuoVadis::RecoveryCode.count', 5 do
      codes = account.generate_recovery_codes
    end
    assert_equal 5, codes.length
    codes.each do |code|
      assert_instance_of String, code
    end
  end

end
