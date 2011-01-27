require 'test_helper'

class ForgottenTest < ActiveSupport::IntegrationCase

  teardown do
    Capybara.reset_sessions!
  end

  test 'user fills in forgotten-password form with invalid username' do
    submit_forgotten_details 'bob'
    assert_equal forgotten_sign_in_path, current_path
    within '.flash.alert' do
      assert page.has_content?("Sorry, we did not recognise you.")
    end
  end

  test 'user without email requests password-change email' do
    user_factory 'Bob', 'bob', 'secret'
    submit_forgotten_details 'bob'
    assert_equal forgotten_sign_in_path, current_path
    within '.flash.alert' do
      assert page.has_content?("Sorry, we don't have an email address for you.")
    end
  end

  test 'user can request password-change email' do
    user_factory 'Bob', 'bob', 'secret', 'bob@example.com'
    submit_forgotten_details 'bob'

    assert_equal root_path, current_path
    within '.flash.notice' do
      assert page.has_content?("We've emailed you a link where you can change your password.")
    end
    assert !ActionMailer::Base.deliveries.empty?
    email = ActionMailer::Base.deliveries.last
    assert_equal ['bob@example.com'],     email.to
    assert_equal ['noreply@example.com'], email.from
    assert_equal 'Change your password',  email.subject
    # Why doesn't this use the default url option set up in test/test_helper.rb#9?
    assert_match Regexp.new(Regexp.escape(change_password_url User.last.token, :host => 'www.example.com')), email.encoded
  end

  test 'user can follow emailed link while valid to change password' do
    user_factory 'Bob', 'bob', 'secret', 'bob@example.com'
    submit_forgotten_details 'bob'
    
    link_in_email = ActionMailer::Base.deliveries.last.encoded[%r{http://.*}].strip
    visit link_in_email
    fill_in :password, :with => 'topsecret'
    click_button 'Change my password'
    assert_equal root_path, current_path
    within '.flash.notice' do
      assert page.has_content?("You have successfully changed your password and you're now signed in.")
    end
    assert_nil User.last.token
    assert_nil User.last.token_created_at
  end

  test 'user cannot change password to an invalid one' do
    user_factory 'Bob', 'bob', 'secret', 'bob@example.com'
    submit_forgotten_details 'bob'
    
    link_in_email = ActionMailer::Base.deliveries.last.encoded[%r{http://.*}].strip
    visit link_in_email
    fill_in :password, :with => ''
    click_button 'Change my password'
    assert_equal change_password_path(User.last.token), current_path
  end

  test 'user cannot change password once emailed link is invalid' do
    user_factory 'Bob', 'bob', 'secret', 'bob@example.com'
    submit_forgotten_details 'bob'
    User.last.update_attributes :token_created_at => 1.day.ago
    
    link_in_email = ActionMailer::Base.deliveries.last.encoded[%r{http://.*}].strip
    visit link_in_email
    assert_equal forgotten_sign_in_path, current_path
    within '.flash.alert' do
      assert page.has_content?("Sorry, this link isn't valid anymore.")
    end
  end

end
