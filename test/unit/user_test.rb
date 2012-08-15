require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'user must have a unique username' do
    User.create :username => 'bob', :password => 'secret'
    assert User.new(:username => 'bob', :password => 'secret').invalid?
  end

  test 'user must have a valid password on create' do
    assert User.create(:username => 'bob', :password => nil).invalid?
    assert User.create(:username => 'bob', :password => '').invalid?
    assert User.create(:username => 'bob', :password => 'secret').valid?
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
    assert user.invalid?

    user.username = 'robert'
    assert user.valid?

    user.username = nil
    assert user.valid?
  end

  test 'create for activation' do
    user = User.new_for_activation :name => 'Bob'
    assert user.valid?

    user = User.new_for_activation :name => 'John', :username => 'john', :password => 'secret'
    assert user.valid?
    assert_not_equal 'john', user.username
    assert_not_equal 'secret', user.password
  end

  test 'ignore blank usernames when authenticating' do
    user = User.new :username => '', :password => ''
    user.class_eval <<-END
      def should_authenticate?; false end
    END
    user.save!

    assert_equal nil, User.authenticate('', '')
  end

end
