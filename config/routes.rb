Rails.application.routes.draw do
  scope :module => 'quo_vadis' do
    get  'sign-in'                 => 'sessions#new',       :as => 'sign_in'
    post 'sign-in'                 => 'sessions#create',    :as => 'sign_in'
    get  'sign-out'                => 'sessions#destroy',   :as => 'sign_out'
    get  'sign-in/forgotten'       => 'sessions#forgotten', :as => 'forgotten_sign_in'
    post 'sign-in/forgotten'       => 'sessions#forgotten', :as => 'forgotten_sign_in'
    constraints :token => /.+/ do
      get  'sign-in/change-password/:token' => 'sessions#edit',   :as => 'change_password'
      put  'sign-in/change-password/:token' => 'sessions#update', :as => 'change_password'
      get  'sign-in/invite/:token'          => 'sessions#invite', :as => 'invitation'
      post 'sign-in/accept/:token'          => 'sessions#accept', :as => 'activation'
    end
  end
end
