Rails.application.routes.draw do
  get 'notifications/read'

  devise_for :users, skip: [:sessions], controllers: { omniauth_callbacks: 'omniauth_callbacks', :registrations => 'registrations' }
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  # 


  #TODO: remove some routes as there will only be Twitter logins
  devise_scope :user do
    get "signin", to: "devise/sessions#new", as: :signin
    delete "logout", to: "devise/sessions#destroy", as: :destroy_user_session
    
    get '/users/connect/:provider', :to => redirect("/users/auth/%{provider}"), :as => 'user_omniauth_connect'
  end
  
  resources :deposit, only: [:index]
  
  resources :notifications, only: [] do
    collection do
      post 'read'
    end
  end
  
  resources :goals, only: [:new, :create] do
    resources :deposit, only: [:new, :create]  do
      collection do
        get 'confirm'
        get 'cancel'
        get 'done'
        get 'refund'
        post 'refund'
      end
    end
  end
  
  resources :commits, only: [:update] do
    collection do
      post 'check_in'
    end
  end
  
  resources :users, path: 'settings', only: [] do
    collection do
      put 'update'
      get 'account'
      get 'profile'
      get 'preference'
      post 'preference'
    end
  end
  
  
  resources :comments, only: [:create, :destroy]
  
  
  match '/finish_signup' => 'users#finish_signup', via: [:get, :patch], :as => :finish_signup
  
  match '/confirmation_sent' => 'home#confirmation_sent', via: [:get], :as => :confirmation_sent
  
  match '/people' => 'users#index', via: [:get], :as => :people
  
  match '/privacy_policy' => 'home#privacy_policy', via: [:get], :as => :privacy_policy
  match '/about' => 'home#about', via: [:get], :as => :about

  
  resources :users, path: '', only: [:show] do
    resources :goals, only: [:index, :show, :update, :destroy]
    resource :follow, only: [:create, :destroy]
  end
  
  
  # You can have the root of your site routed with "root"
  root to: "home#index"


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
