Rails.application.routes.draw do
  get 'sessions' => 'sessions#show'
  resources :users, only: :index
  resources :sessions, only: :create
  resources :entries, only: %i{ index destroy }
end
