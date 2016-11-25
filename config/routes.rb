Rails.application.routes.draw do
  resources :users, only: :index
  resources :sessions, only: :create
  get 'sessions' => 'sessions#show'
end
