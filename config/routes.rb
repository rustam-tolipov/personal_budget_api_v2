Rails.application.routes.draw do

  mount Rswag::Ui::Engine => '/'
  mount Rswag::Api::Engine => '/api-docs'

  scope :api do
    scope :v1 do
      devise_for :accounts,
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

      devise_scope :account do
        get  '/auth/me',    to: 'api/v1/accounts#me',      as: :me
        put  '/auth/me',    to: 'api/v1/accounts#update',  as: :update_account
        post '/password/forgot', to: 'api/v1/passwords#forgot', as: :forgot
        post '/password/reset',  to: 'api/v1/passwords#reset',  as: :reset
      end
    end
  end

end
