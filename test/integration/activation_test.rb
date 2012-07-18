require 'test_helper'

class ActivationTest < ActiveSupport::IntegrationCase

  teardown do
    Capybara.reset_sessions!
  end

  test 'a user can be invited' do
    user = User.new_for_activation :name => 'Bob', :email => 'bob@example.com'
    assert user.save
    assert QuoVadis::SessionsController.new.invite_to_activate user

    assert ActionMailer::Base.deliveries.last
    assert !ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last

    assert_equal ['bob@example.com'],      email.to
    assert_equal ['noreply@example.com'],  email.from
    assert_equal 'Activate your account',  email.subject
    # Why doesn't this use the default url option set up in test/test_helper.rb#9?
    assert_match Regexp.new(Regexp.escape(invitation_url user.token, :host => 'www.example.com')), email.encoded
  end

  test 'a user without email cannot be invited' do
    user = User.new_for_activation :name => 'Bob'
    assert user.save
    assert ! QuoVadis::SessionsController.new.invite_to_activate(user)
  end

  test 'user can accept a valid invitation and set valid credentials' do
    user = User.new_for_activation :name => 'Bob', :email => 'bob@example.com'
    user.generate_token
    assert user.save

    visit invitation_url(user.token, :host => 'www.example.com')
    fill_in 'Username', :with => 'bob'
    fill_in 'Password', :with => 'secret'
    click_button 'Save my details'
    assert_equal root_path, current_path
    within '.flash.notice' do
      assert page.has_content?("Your account is active and you're now signed in.")
    end
    assert_nil user.reload.token
    assert_nil user.token_created_at
  end

  test 'user can accept a valid invitation but not set invalid credentials' do
    user = User.new_for_activation :name => 'Bob', :email => 'bob@example.com'
    user.generate_token
    assert user.save

    visit invitation_url(user.token, :host => 'www.example.com')
    fill_in 'Username', :with => 'bob'
    fill_in 'Password', :with => ''
    click_button 'Save my details'
    assert_equal activation_path(user.token), current_path
    assert user.reload.token
    assert user.token_created_at
  end

  test 'user cannot view an expired invitation' do
    user = User.new_for_activation :name => 'Bob', :email => 'bob@example.com'
    user.generate_token
    assert user.save
    user.update_attributes :token_created_at => 1.day.ago

    visit invitation_url(user.token, :host => 'www.example.com')
    assert_equal root_path, current_path
    within '.flash.alert' do
      assert page.has_content?("Sorry, this link isn't valid anymore.")
    end
  end

  test 'user cannot accept an expired invitation' do
    user = User.new_for_activation :name => 'Bob', :email => 'bob@example.com'
    user.generate_token
    assert user.save

    visit invitation_url(user.token, :host => 'www.example.com')
    user.update_attributes :token_created_at => 1.day.ago
    fill_in 'Username', :with => 'bob'
    fill_in 'Password', :with => 'secret'
    click_button 'Save my details'
    assert_equal root_path, current_path
    within '.flash.alert' do
      assert page.has_content?("Sorry, this link isn't valid anymore.")
    end
  end

  test 'data can be passed to invitation email' do
    user = User.new_for_activation :name => 'Bob', :email => 'bob@example.com'
    assert user.save
    assert QuoVadis::SessionsController.new.invite_to_activate user, :foo => 'Barbaz'
    email = ActionMailer::Base.deliveries.last
    assert_match Regexp.new('Barbaz'), email.encoded
  end
end
