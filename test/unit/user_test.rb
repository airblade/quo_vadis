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
    assert user.update_attributes(:username => 'Robert', :password => nil)
    assert user.update_attributes(:username => 'Robert', :password => '')
    assert User.last.has_matching_password?('secret')
  end

  test 'user must have a valid password when updating password' do
    user = User.create :username => 'bob', :password => 'secret'
    assert user.update_attributes(:password => 'topsecret')
  end

  test 'has_matching_password?' do
    User.create :username => 'bob', :password => 'secret'
    user = User.last
    assert user.has_matching_password?('secret')
  end

  test 'conditional validation' do
    user = User.new
    user.class_eval <<-END
      def should_authenticate?
        username == 'bob'
      end
    END
    user.username = 'bob'
    assert !user.valid?

    user.username = 'robert'
    assert user.valid?

    user.username = nil
    assert user.valid?
  end

end
