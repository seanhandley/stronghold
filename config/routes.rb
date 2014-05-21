Rails.application.routes.draw do

  get '/css', :controller => 'support/dashboard', :action => 'css'
  get '/components', :controller => 'support/dashboard', :action => 'components'

  namespace :support do
    root :to => 'dashboard#index'
    resources :instances
    resources :users
    resources :roles
  end

  resources :sessions

  get 'sign_in', :controller => 'sessions', :action => 'new'

  root :to => 'support/dashboard#index'

end
