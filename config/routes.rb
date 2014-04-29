Rails.application.routes.draw do

  get '/css', :controller => 'support/dashboard', :action => 'css'
  get '/components', :controller => 'support/dashboard', :action => 'components'

  namespace :support do
    root :to => 'dashboard#index'
    resources :sessions
  end

  root :to => 'support/dashboard#index'

end
