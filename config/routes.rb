Rails.application.routes.draw do
  get 'sessions' => 'sessions#show'
  resources :users, only: :index
  resources :sessions, only: :create
  resources :projects, only: %i{ index create update destroy }
  resources :clients, only: %i{ index create update destroy }

  get '/entries', to: 'entries#running', constraints: ->(r) { r.params['filter'] && r.params['filter']['running'] == '1' }
  resources :entries, only: %i{ index create update destroy }
end
