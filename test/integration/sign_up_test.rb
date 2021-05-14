require 'test_helper'

class SignUpTest < IntegrationTest

  test 'successful sign up' do
    assert_difference 'User.count' do
      post "/users", params: {
        user: {
          name:                  'Bob',
          email:                 'billy@example.com',
          password:              '123456789abc',
          password_confirmation: '123456789abc'
        }
      }, headers: { 'HTTP_USER_AGENT' => 'Blah' }
      assert_redirected_to '/articles'
      follow_redirect!
      assert_select 'p', 'Public Articles'
    end
  end


  test 'failed sign up' do
    assert_no_difference 'User.count' do
      post "/users", params: {
        user: {
          name:     'Bob',
          email:    'billy@example.com',
          password: 'x'
        }
      }
      assert_response :success
    end
  end

end
