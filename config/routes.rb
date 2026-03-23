Rails.application.routes.draw do

  mount Rswag::Ui::Engine => '/'
  mount Rswag::Api::Engine => '/api-docs'
  
  namespace :api do
    namespace :v1 do

      get '/search', to: 'users#search'
      get '/member/:member_id/transactions/search', to: 'transactions#search'
      
      resources :members, only: [ :index, :show, :destroy, :update] do
        resources :categories, only: [:create, :index, :show, :update]
      end

      post '/members', to: 'members#create'
      get '/settings_members', to: 'members#settings_members', as: :settings_members

      get ':id/recent_transactions/', to: 'transactions#recent_transactions', as: :recent_transactions

      post '/member/:id/category/:category_id/remove', to: 'categories#remove_from_member', as: :remove_from_member

      get '/categories', to: 'categories#index', as: :categories
      get '/:member_id/categories/', to: 'categories#index_by_member', as: :categories_by_member

      post '/categories', to: 'categories#create'
      get '/categories/:id', to: 'categories#show', as: :category
      get '/incomes/:member_id/categories/', to: 'categories#incomes', as: :incomes
      get '/expenses/:member_id/categories', to: 'categories#expenses', as: :expenses
      get '/:member_id/categories/:id/transactions/', to: 'transactions#index', as: :transactions
      post '/:member_id/categories/:id/transactions/', to: 'transactions#create', as: :create_transaction
      delete '/transactions/:id', to: 'transactions#destroy', as: :destroy_transaction
      put '/member/:member_id/categories/:category_id/transactions/:id', to: 'transactions#update', as: :update_transaction
    end
  end
  
  get 'users/index'
  scope :api do
    scope :v1 do
      devise_for :users,
                 path: 'auth',
                 path_names: {
                   sign_in: 'login',
                   sign_out: 'logout',
                   registration: 'signup'
                 },
                 controllers: {
                   registrations: 'api/v1/registrations',
                   sessions: 'api/v1/sessions',
                 }, defaults: { format: :json }
      devise_scope :user do
        get '/auth/me', to: 'api/v1/users#me', as: :user_root
        get '/auth/users', to: 'api/v1/users#index', as: :users
        get '/auth/users/:id', to: 'api/v1/users#show', as: :user
        get '/users/show/:username', to: 'api/v1/users#show_by_username', as: :show_by_username
        put '/auth/users/:id', to: 'api/v1/users#update', as: :update_user
        delete '/auth/users', to: 'api/v1/users#destroy', as: :destroy_user
        post 'password/forgot', to: 'api/v1/passwords#forgot', as: :forgot
        post 'password/reset', to: 'api/v1/passwords#reset', as: :reset
      end
    end
  end
end
