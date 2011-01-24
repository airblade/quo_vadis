Rails.application.routes.draw do |map|
  scope :module => 'quo_vadis' do
    get  'sign-in'  => 'sessions#new',     :as => 'sign_in'
    post 'sign-in'  => 'sessions#create',  :as => 'sign_in'
    get  'sign-out' => 'sessions#destroy', :as => 'sign_out'
  end
end
