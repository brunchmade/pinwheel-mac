Rails.application.routes.draw do
  root 'sessions#new'

  resources :messages do
    resources :comments
  end
  resource  :session

  post 'pusher/auth'
end
