require 'test_helper'

class LocaleTest < ActiveSupport::IntegrationCase

  teardown do
    Capybara.reset_sessions!
  end

  test 'sign_in.before flash' do
    visit new_article_path
    within '.flash' do
      assert page.has_content?('Please sign in first.')
    end
  end

  test 'sign_in.after flash' do
    user_factory 'Bob', 'bob', 'secret'
    sign_in_as 'bob', 'secret'
    within '.flash' do
      assert page.has_content?('You have successfully signed in.')
    end
  end

  test 'sign_in.failed flash' do
    sign_in_as 'bob', 'secret'
    within '.flash' do
      assert page.has_content?('Sorry, we did not recognise you.')
    end
  end

  test 'sign_out flash' do
    visit sign_out_path
    within '.flash' do
      assert page.has_content?('You have successfully signed out.')
    end
  end

  test 'sign_in.before flash is optional' do
    begin
      I18n.backend.store_translations :en, {:quo_vadis => {:flash => {:sign_in => {:before => ''}}}}
      visit new_article_path
      assert page.has_no_css?('div.flash')
    ensure
      I18n.reload!
    end
  end

  test 'sign_in.after flash is optional' do
    user_factory 'Bob', 'bob', 'secret'
    begin
      I18n.backend.store_translations :en, {:quo_vadis => {:flash => {:sign_in => {:after => ''}}}}
      sign_in_as 'bob', 'secret'
      assert page.has_no_css?('div.flash')
    ensure
      I18n.reload!
    end
  end

  test 'sign_in.failed flash is optional' do
    begin
      I18n.backend.store_translations :en, {:quo_vadis => {:flash => {:sign_in => {:failed => ''}}}}
      sign_in_as 'bob', 'secret'
      assert page.has_no_css?('div.flash')
    ensure
      I18n.reload!
    end
  end

  test 'sign_in.blocked flash' do
    QuoVadis.blocked = true
    user_factory 'Bob', 'bob', 'secret'
    sign_in_as 'bob', 'secret'
    within '.flash' do
      assert page.has_content?('Sorry, your account is blocked.')
    end
  end

  test 'sign_in.blocked flash is optional' do
    begin
      I18n.backend.store_translations :en, {:quo_vadis => {:flash => {:sign_in => {:blocked => ''}}}}
      QuoVadis.blocked = true
      user_factory 'Bob', 'bob', 'secret'
      sign_in_as 'bob', 'secret'
      assert page.has_no_css?('div.flash')
    ensure
      I18n.reload!
    end
  end

  test 'sign_out flash is optional' do
    begin
      I18n.backend.store_translations :en, {:quo_vadis => {:flash => {:sign_out => ''}}}
      visit sign_out_path
      assert page.has_no_css?('div.flash')
    ensure
      I18n.reload!
    end
  end

  test 'forgotten.unknown flash' do
    submit_forgotten_details 'bob'
    within '.flash.alert' do
      assert page.has_content?('Sorry, we did not recognise you.')
    end
  end

  test 'forgotten.unknown flash is optional' do
    begin
      I18n.backend.store_translations :en, {:quo_vadis => {:flash => {:forgotten => {:unknown => ''}}}}
      submit_forgotten_details 'bob'
      assert page.has_no_css?('div.flash')
    ensure
      I18n.reload!
    end
  end

  test 'forgotten.no_email flash' do
    user_factory 'Bob', 'bob', 'secret'
    submit_forgotten_details 'bob'
    within '.flash.alert' do
      assert page.has_content?("Sorry, we don't have an email address for you.")
    end
  end

  test 'forgotten.no_email flash is optional' do
    begin
      I18n.backend.store_translations :en, {:quo_vadis => {:flash => {:forgotten => {:no_email => ''}}}}
      user_factory 'Bob', 'bob', 'secret'
      submit_forgotten_details 'bob'
      assert page.has_no_css?('div.flash')
    ensure
      I18n.reload!
    end
  end

  test 'forgotten.sent_email flash' do
    user_factory 'Bob', 'bob', 'secret', 'bob@example.com'
    submit_forgotten_details 'bob'
    within '.flash.notice' do
      assert page.has_content?("We've emailed you a link where you can change your password.")
    end
  end

  test 'forgotten.sent_email flash is optional' do
    begin
      I18n.backend.store_translations :en, {:quo_vadis => {:flash => {:forgotten => {:sent_email => ''}}}}
      user_factory 'Bob', 'bob', 'secret', 'bob@example.com'
      submit_forgotten_details 'bob'
      assert page.has_no_css?('div.flash')
    ensure
      I18n.reload!
    end
  end

  test 'forgotten.invalid_token flash' do
    visit change_password_path('123')
    within '.flash.alert' do
      assert page.has_content?("Sorry, this link isn't valid anymore.")
    end
  end

  test 'forgotten.invalid_token flash is optional' do
    begin
      I18n.backend.store_translations :en, {:quo_vadis => {:flash => {:forgotten => {:invalid_token => ''}}}}
      visit change_password_path('123')
      assert page.has_no_css?('div.flash')
    ensure
      I18n.reload!
    end
  end

  test 'forgotten.password_changed flash' do
    user_factory 'Bob', 'bob', 'secret', 'bob@example.com'
    User.last.generate_token
    visit change_password_path(User.last.token)
    fill_in :password, :with => 'topsecret'
    click_button 'Change my password'
    within '.flash.notice' do
      assert page.has_content?("You have successfully changed your password and you're now signed in.")
    end
  end

  test 'forgotten.password_changed flash is optional' do
    begin
      I18n.backend.store_translations :en, {:quo_vadis => {:flash => {:forgotten => {:password_changed => ''}}}}
      user_factory 'Bob', 'bob', 'secret', 'bob@example.com'
      User.last.generate_token
      visit change_password_path(User.last.token)
      fill_in :password, :with => 'topsecret'
      click_button 'Change my password'
      assert page.has_no_css?('div.flash')
    ensure
      I18n.reload!
    end
  end

end
