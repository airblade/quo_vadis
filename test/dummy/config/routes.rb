Dummy::Application.routes.draw do
  resources :articles
  resources :users
  root :to => 'articles#index'
end
