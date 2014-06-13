Rails.application.routes.draw do

  get '/css', :controller => 'support/dashboard', :action => 'css'
  get '/components', :controller => 'support/dashboard', :action => 'components'

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
  end

  resources :sessions

  get 'sign_in', :controller => 'sessions', :action => 'new'

  root :to => 'support/dashboard#index'

  if Rails.env.production?
    get '404', :to => 'errors#page_not_found'
    get '422', :to => 'errors#server_error'
    get '500', :to => 'errors#server_error'
  end

end