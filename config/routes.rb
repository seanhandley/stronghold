Rails.application.routes.draw do

  namespace :support do
    root :to => 'dashboard#index'
    resources :instances
    resources :users
    resources :roles
    get 'tickets', :controller => 'tickets', :action => 'index'
    namespace :api, defaults: {format: :json} do
      resources :tickets, only: [:index, :show] do
        resources :comments, only: [:create, :update, :destroy]
      end
    end
    delete 'role/:role_id/user/:user_id', :controller => 'role_users', :action => 'destroy', :as => 'remove_role_user'
    resources :role_users, only: [:create]
    resources :invites, only: [:create]
  end

  resources :sessions

  get 'signup/:token', :controller => 'signups', :action => 'edit', :as => 'signup_begin'
  post 'signup/:token', :controller => 'signups', :action => 'update', :as => 'signup_complete'

  get 'sign_in', :controller => 'sessions', :action => 'new'

  root :to => 'support/dashboard#index'

  if Rails.env.production?
    get '404', :to => 'errors#page_not_found'
    get '422', :to => 'errors#server_error'
    get '500', :to => 'errors#server_error'
  end

end
