require 'test_helper'

class BlockedTest < ActiveSupport::IntegrationCase

  test 'sign-in process can be blocked' do
    user_factory 'Bob', 'bob', 'secret'
    user_factory 'Jim', 'jim', 'secret'

    QuoVadis.blocked = Proc.new do |controller|
      controller.params[:username] == 'bob'
    end

    sign_in_as 'bob', 'secret'
    within '.flash' do
      assert page.has_content?('Sorry, your account is blocked.')
    end

    sign_in_as 'jim', 'secret'
    within '.flash' do
      assert page.has_content?('You have successfully signed in.')
    end
  end
end
