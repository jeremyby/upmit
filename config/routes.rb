Rails.application.routes.draw do
  devise_for :users, skip: [:sessions], controllers: { omniauth_callbacks: 'omniauth_callbacks', :registrations => 'registrations' }
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  # 

  devise_scope :user do
    get "login", to: "devise/sessions#new", as: :new_user_session
    post 'login', to: "devise/sessions#create", as: :user_session
    delete "logout", to: "devise/sessions#destroy", as: :destroy_user_session
    get "signup", to: "devise/registrations#new"
    get "forgot_password", to: "devise/passwords#new"
  end
  
  resources :deposit, only: [:index]
  
  resources :goals, except: [:show, :edit, :update, :destroy] do
    resources :deposit, except: [:index]  do
      collection do
        get 'confirm'
        get 'cancel'
        get 'done'
      end
    end
  end
  
  resources :commits, only: [:update] do
    post 'check'
    post 'fail'
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

  
  resources :users, path: '', only: [:show] do
    resources :goals, only: [:index, :show, :update]
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
