Rails.application.routes.draw do

  get '/css', :controller => 'support/dashboard', :action => 'css'
  get '/components', :controller => 'support/dashboard', :action => 'components'

  namespace :support do
    root :to => 'dashboard#index'
    resources :instances
    resources :users
    resources :roles
    resources :tickets
  end

  resources :sessions

  get 'sign_in', :controller => 'sessions', :action => 'new'

  root :to => 'support/dashboard#index'
  #root :to => 'support/test'

  if Rails.env.production?
    get '404', :to => 'errors#page_not_found'
    get '422', :to => 'errors#server_error'
    get '500', :to => 'errors#server_error'
  end

end