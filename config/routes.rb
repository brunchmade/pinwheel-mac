Rails.application.routes.draw do
  root 'sessions#new'

  resources :messages do
    resources :comments
    member do
      get :backfill
      get :next
      get :reload_all
      post :update_user_count
    end
  end
  resources :pusher, only: [] do
    collection do
      post :auth
    end
  end
  resources :sessions, only: [:destroy, :new]

  get '/soundcloud/callback', to: 'sessions#soundcloud'
  post :login, to: 'sessions#create'
end
