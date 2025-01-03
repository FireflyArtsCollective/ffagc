Rails.application.routes.draw do
  mount Judge::Engine => '/judge'

  root to: 'home#index'

  get 'password_resets/' => 'password_resets#index'
  get 'password_resets/new'
  get 'password_resets/edit'

  get 'admins/' => 'admins#index'
  post 'admins/index' => 'admins#index'
  get 'admins/voters' => 'admins#voters'

  resources :artists, :grant_submissions
  resources :grants, except: [:show] do
    collection do
      get 'levels'
    end
  end

  get 'grants/levels'

  resources :admins, only: [:new, :create, :index]
  namespace :admins do
    resources :grant_submissions, only: [:index] do
      get 'discuss'
      collection do
        post 'send_fund_emails'
        post 'send_question_emails'
      end
    end
    resources :voter_submission_assignments, only: [] do
      collection do
        post 'assign'
        delete 'destroy'
      end
    end
  end

  resources :grant_submissions do
    member do
      get 'discuss'
      post 'generate_contract'
    end
  end

  resources :tags, only: [:new, :create, :edit, :update]

  resources :submission_tags, only: [:new, :create, :edit, :update]

  resources :proposals, only: [:destroy]

  resources :voters, only: [:new, :create, :update, :index, :show] do
    member do
      post 'verify'
    end
  end

  resources :votes, only: [:index]
  resource :votes, only: [:update]

  resources :account_activations, only: [:show, :create]

  resources :password_resets, only: [:new, :create, :edit, :update]

  namespace :sessions do
    resource :admin, only: [:new, :create, :destroy]
    resource :artist, only: [:new, :create, :destroy]
    resource :voter, only: [:new, :create, :destroy] do
      member do
        get 'unverified'
      end
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
