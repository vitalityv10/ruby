Rails.application.routes.draw do
  get "welcome/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  root 'products#index'
  resources :products, only: [:index, :show] do
    resources :reviews, only: [:create, :destroy]
  end
  resource :cart, only: [:show]
  resources :line_items, only: [:create, :update, :destroy]
  resources :categories, only: [] do
    resources :products, only: [:index]
  end
  # Defines the root path route ("/")
  # root "posts#index"
  get  "register", to: "users#new"
  resources :users, only: [:create]
  get  "login",  to: "sessions#new"
  post "login",  to: "sessions#create"
  namespace :admin do
    root to: "dashboard#index"
    resources :products, except: [:show] do
      collection { get :bulk; post :bulk_create }
    end
    resources :categories, only: [:index, :create, :destroy]
    resources :orders, only: [:index, :show] do
      member { patch :update_status; patch :mark_paid }
    end
    resources :feedbacks, only: [:index, :show] do
      member { patch :reply }
    end
  end
  resource :profile, only: [:show]
  resources :orders, only: [:new, :create, :show] do
    member { patch :cancel }
  end
  get  "contact", to: "feedbacks#new"
  post "contact", to: "feedbacks#create"
  delete "logout", to: "sessions#destroy"
end
