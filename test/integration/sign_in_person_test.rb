require 'test_helper'

class SignInPersonTest < ActiveSupport::IntegrationCase

  # NOTE: it would be great if I could figure out how to re-initialise the method's
  # mixed into the controller with the new model.
  test 'successful sign in for a non-user model' do
    puts <<-END
    NOTE: this test (#{__FILE__}) has to be run individually like this:

    1. Change lib/quo_vadis.rb's @@model to 'Person'.
    2. Uncomment the test code.
    3. bundle exec ruby -Ilib:test #{__FILE__}

    END

    # person_factory 'James', 'jim', 'secret'
    # sign_in_as 'jim', 'secret'

    # assert_equal root_path, current_path
    # within '.flash.notice' do
    #   assert page.has_content?('You have successfully signed in.')
    # end
  end

end
