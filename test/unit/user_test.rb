require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'user must have a valid password on create' do
    assert !User.create(:username => 'bob', :password => nil).valid?
    assert !User.create(:username => 'bob', :password => '').valid?
    assert  User.create(:username => 'bob', :password => 'secret').valid?
  end

  test 'user need not supply password when updating other attributes' do
    User.create :username => 'bob', :password => 'secret'
    user = User.last  # reload from database so password is nil
    assert_nil user.password
    assert user.update_attributes(:username => 'Robert')
  end

  test 'user must have a valid password when updating password' do
    user = User.create :username => 'bob', :password => 'secret'
    assert !user.update_attributes(:password => '')
    assert !user.update_attributes(:password => nil)
    assert  user.update_attributes(:password => 'topsecret')
  end

  test 'has_matching_password?' do
    User.create :username => 'bob', :password => 'secret'
    user = User.last
    assert user.has_matching_password?('secret')
  end

end
