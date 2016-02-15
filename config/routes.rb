Rails.application.routes.draw do
  root 'sessions#new'

  resources :messages do
    resources :comments
    member do
      get 'backfill'
      get 'next'
    end
  end

  resource  :session

  match 'soundcloud/callback', to: 'sessions#soundcloud', via: [:get]
  post 'pusher/auth'
  match '/login', to: 'sessions#create', via: [:post]
end
