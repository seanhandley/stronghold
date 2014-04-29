Rails.application.routes.draw do

   root 'dashboard#index'

   get '/css', :controller => 'dashboard', :action => 'css'
   get '/components', :controller => 'dashboard', :action => 'components'

end
