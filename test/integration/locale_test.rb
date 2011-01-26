require 'test_helper'

class LocaleTest < ActiveSupport::IntegrationCase

  teardown do
    Capybara.reset_sessions!
  end

  test 'before_sign_in flash' do
    visit new_article_path
    within '.flash' do
      assert page.has_content?('Please sign in first.')
    end
  end

  test 'after_sign_in flash' do
    user_factory 'Bob', 'bob', 'secret'
    sign_in_as 'bob', 'secret'
    within '.flash' do
      assert page.has_content?('You have successfully signed in.')
    end
  end

  test 'failed_sign_in flash' do
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

  test 'before_sign_in flash is optional' do
    begin
      I18n.backend.store_translations :en, {:quo_vadis => {:flash => {:before_sign_in => ''}}}
      visit new_article_path
      assert page.has_no_css?('div.flash')
    ensure
      I18n.reload!
    end
  end

  test 'after_sign_in flash is optional' do
    user_factory 'Bob', 'bob', 'secret'
    begin
      I18n.backend.store_translations :en, {:quo_vadis => {:flash => {:after_sign_in => ''}}}
      sign_in_as 'bob', 'secret'
      assert page.has_no_css?('div.flash')
    ensure
      I18n.reload!
    end
  end

  test 'failed_sign_in flash is optional' do
    begin
      I18n.backend.store_translations :en, {:quo_vadis => {:flash => {:failed_sign_in => ''}}}
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
end
