# frozen_string_literal: true

QuoVadis::Engine.routes.draw do
  get    'login',  to: 'sessions#new'
  post   'login',  to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  resources :logs, only: :index

  resources :sessions, only: [:index, :destroy]

  resource  :password, only: [:edit, :update]

  resources :password_resets, only: [:new, :create, :index]
  get '/pwd-reset/:token', to: 'password_resets#edit',   as: 'edit_password_reset'
  put '/pwd-reset/:token', to: 'password_resets#update', as: 'password_reset'

  resources :confirmations, only: [:new, :create, :index] do
    collection do
      get :edit_email
      put :update_email
      post :resend
    end
  end
  get '/confirm/:token', to: 'confirmations#edit',   as: 'edit_confirmation'
  put '/confirm/:token', to: 'confirmations#update', as: 'confirmation'

  resources :totps, only: [:new, :create] do
    collection do
      get :challenge
      post :authenticate
    end
  end

  resources :recovery_codes, only: [:index] do
    collection do
      get :challenge
      post :authenticate
      post :generate
    end
  end

  resource :twofa, path: '2fa'
end


Rails.application.routes.draw do
  mount QuoVadis::Engine, at: QuoVadis.mount_point, as: :quo_vadis
end
