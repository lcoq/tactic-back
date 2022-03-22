Rails.application.routes.draw do
  get 'sessions' => 'sessions#show'

  resources :users, only: %i{ index show update }
  resources :user_configs, only: %i{ index update }, path: '/users/:user_id/configs'

  get '/users/:user_id/notification_lists/latest', to: 'user_notification_lists#latest'
  patch '/users/:user_id/notification_lists/:id', to: 'user_notification_lists#update'
  delete '/users/:user_id/notifications/:id', to: 'user_notifications#destroy'

  resources :sessions, only: :create
  resources :projects, only: %i{ index show create update destroy }
  resources :clients, only: %i{ index create update destroy }

  get '/entries', to: 'entries#running', constraints: ->(r) { r.params['filter'] && r.params['filter']['running'] == '1' }
  resources :entries, only: %i{ index show create update destroy }

  get '/stats/daily', to: 'entries_stat_groups#daily'
  get '/stats/monthly', to: 'entries_stat_groups#monthly'

  namespace :teamwork do
    resources :domains, only: %i{ index create update destroy }
    resources :user_configs, only: %i{ index update }, path: '/configs'
  end
end
