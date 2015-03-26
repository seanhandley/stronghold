Rails.application.routes.draw do

  require 'sidekiq/web'
  require_relative "../lib/constraints/staff_constraint"
  mount Sidekiq::Web => '/queue', :constraints => StaffConstraint.new

  mount RailsAdmin::Engine => '/data', as: 'rails_admin'

  mount Starburst::Engine => "/starburst"

  namespace :support do
    root :to => 'dashboard#index'
    resources :instances
    resources :organizations, only: [:update]
    get '/edit_organization', :controller => 'organizations', :action => 'index', :as => 'edit_organization'
    resources :users, only: [:update, :destroy]
    get '/profile', :controller => 'users', :action => 'index'
    resources :roles
    resources :tickets, only: [:index, :show]
    namespace :api, defaults: {format: :json} do
      resources :tickets, only: [:index, :create, :update] do
        resources :comments, :controller => "ticket_comments", only: [:create]
      end
    end
    delete 'role/:role_id/user/:user_id', :controller => 'role_users', :action => 'destroy', :as => 'remove_role_user'
    resources :role_users, only: [:create]
    resources :invites, only: [:create]
    resources :audits, only: [:index]
    get '/usage', :controller => 'usage', :action => 'index'
  end

  namespace :ext do
    post '/contacts/find', :controller => 'contacts', :action => 'find'
  end

  # TODO: Add subnets to lib/admin_constraint.rb
  #constraints AdminConstraint.new do
    namespace :admin do
      root :to => 'dashboard#index'
      resources :customers, only: [:new, :create]
      resources :usage, only: [:index, :create]
    end
  #end

  resources :sessions, only: [:create, :destroy, :new, :index]
  resources :resets, only: [:create, :new, :show, :update]

  get 'signup/:token', :controller => 'signups', :action => 'edit', :as => 'signup_begin'
  post 'signup/:token', :controller => 'signups', :action => 'update', :as => 'signup_complete'
  get 'signup', :controller => 'signups', :action => 'new', :as => 'new_signup'
  post 'signup', :controller => 'signups', :action => 'create', :as => 'create_signup'
  get 'pay', :controller => 'signups', :action => 'take_payment', :as => 'take_payment'
  post 'precheck', :controller => 'signups', :action => 'precheck'

  post 'salesforce', :controller => 'salesforce', :action => 'update'

  get 'sign_in', :controller => 'sessions', :action => 'new'

  root :to => 'support/dashboard#index'

  if Rails.env.production?
    get '404', :to => 'errors#page_not_found'
    get '422', :to => 'errors#server_error'
    get '500', :to => 'errors#server_error'
  end

end