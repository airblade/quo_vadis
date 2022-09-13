Rails.application.routes.draw do
  resources :users
  get '/sign_ups/confirmed', to: 'sign_ups#confirmed', as: 'after_signup'
  resources :sign_ups
  resources :articles do
    collection do
      get 'secret'
      get 'also_secret'
      get 'very_secret'
    end
  end
  get '/articles/secret', as: 'after_login'
  root 'articles#index'
end
