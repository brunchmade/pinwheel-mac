Rails.application.routes.draw do
  root 'sessions#new'

  resources :messages do
    resources :comments
    member do
      get 'backfill'
    end
  end

  resource  :session

  post 'pusher/auth'
end
