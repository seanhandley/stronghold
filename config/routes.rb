require 'soulheart/server'

Rails.application.routes.draw do
  apipie unless ['test', 'acceptance'].include?(Rails.env)

  require 'sidekiq/web'

  mount Sidekiq::Web => '/admin/sidekiq', :constraints => Constraints::StaffConstraint.new
  mount ClockworkWeb::Engine => '/admin/clockwork', :constraints => Constraints::StaffConstraint.new

  mount Starburst::Engine => "/starburst"

  mount Harbour::Engine => "/api"

  namespace :support, path: 'account' do
    root :to => 'dashboard#index'
    resources :instances
    resources :organizations, only: [:update]
    get '/details', :controller => 'organizations', :action => 'index', :as => 'edit_organization'
    resources :users, only: [:update, :destroy]
    get '/profile', :controller => 'users', :action => 'index'
    resources :roles, except: [:new, :edit, :show], path: 'team'
    resources :quotas, only: [:index], path: 'limits'
    resources :cards, only: [:new, :create]
    resources :projects, except: [:edit, :new, :show]
    resources :manage_cards, except: [:new, :edit, :show]
    resources :tickets, only: [:index, :show]
    namespace :api, defaults: {format: :json} do
      post 'attachments/:ticket_id', :controller => 'attachments', :action => 'create', :as => 'create_attachment'
      resources :tickets, only: [:index, :create, :update] do
        resources :comments, :controller => "ticket_comments", only: [:create]
        collection do
          post '/read', :controller => 'tickets', :action => 'read'
        end
      end
    end
    delete 'role/:role_id/organization_user/:organization_user_id', :controller => 'organization_user_roles', :action => 'destroy', :as => 'remove_organization_user_role'
    resources :organization_user_roles, only: [:create]
    resources :invites, only: [:create, :destroy]
    resources :audits, only: [:index]
    put '/change_organizations', :controller => 'change_organizations', :action => 'change'
    get '/usage', :controller => 'usage', :action => 'index'
    get '/graph/data', :controller => 'graphs', :action => 'data', :defaults => { :format => 'json' }

    get  'terminal', :controller => 'terminal', :action => 'index'
    post 'terminal_command', :controller => 'terminal', :action => 'run_command', :defaults => { :format => 'js' }
    get 'terminal_tab_complete', :controller => 'terminal', :action => 'terminal_tab_complete', :defaults => { :format => 'js' }
  end

  namespace :ext do
    post '/contacts/find', :controller => 'contacts', :action => 'find'
    post '/unread', :controller => 'unread', :action => 'create'
  end

  constraints Constraints::StaffConstraint.new do
    namespace :admin do
      mount Soulheart::Server, :at => "/searcher"
      root :to => 'customers#index'
      resources :customers, except: [:destroy] do
        resources :projects
        resources :users, only: [:index, :destroy]
      end
      resources :usage, only: [:show, :update]
      resources :free_ips, only: [:index]
      resources :account_migrations, only: [:update]
      resources :audits, only: [:show]
      resources :states, only: [:show]

      resources :organization_assignments, only: [:create, :destroy, :update]
      resources :quotas, except: [:create, :new, :destroy, :show] do
        member do
          post 'mail'
        end
      end
      resources :frozen_customers, only: [:index, :update] do
        member do
          post 'mail'
        end
        member do
          post 'charge'
        end
      end
      resources :invites, only: [:destroy, :update]

      namespace :utilities do
        root :to => 'dashboard#index'
        resources :resellers, only: [:index]
        resources :announcements, only: [:index, :create, :destroy]
        resources :vouchers, except: [:new, :edit, :show]
        resources :sanity, only: [:index]
        resources :online_users, only: [:index]
        resources :stuck_ips, only: [:index, :destroy]
        resources :pending_invoices, only: [:index, :update, :destroy]
        resources :queue, only: [:index] do
          collection do
            put 'restart'
          end
        end
        resources :scheduler, only: [:index] do
          collection do
            put 'restart'
          end
        end
        resources :system_info, only: [:index]
      end
    end
  end


  resources :sessions, only: [:create, :destroy, :new, :index]
  resources :resets, only: [:create, :new, :show, :update]

  get 'membership/:token', :controller => 'memberships', :action => 'confirm', :as => 'membership_begin'
  post 'membership/:token', :controller => 'memberships', :action => 'create', :as => 'membership_complete'
  get 'membership/thanks/:organization_id', :controller => 'memberships', :action => 'thanks', :as => 'membership_thanks'
  get 'signup/:token', :controller => 'signups', :action => 'edit', :as => 'signup_begin'
  post 'signup/:token', :controller => 'signups', :action => 'update', :as => 'signup_complete'
  get 'signup', :controller => 'signups', :action => 'new', :as => 'new_signup'
  post 'signup', :controller => 'signups', :action => 'create', :as => 'create_signup'
  post 'sign_out', :controller => 'sessions', :action => 'destroy', :as => 'signout'
  get 'sign_out', :controller => 'sessions', :action => 'destroy', :as => 'signout_get'
  post 'wait_list', :controller => 'wait_list_entries', :action => 'create', :as => 'wait_list'
  post 'precheck', :controller => 'ajax', :action => 'precheck'
  post 'cc_submit', :controller => 'ajax', :action => 'cc_submit'
  post 'reauthorise', :controller => 'support/organizations', :action => 'reauthorise'
  post 'close_account', :controller => 'support/organizations', :action => 'close'
  post 'voucher_precheck', :controller => 'vouchers', :action => 'precheck'
  get 'activate', :controller => 'support/cards', :action => 'new'
  get 'activated', :controller => 'support/dashboard', :action => 'index'
  get 'thanks', :controller => 'signups', :action => 'thanks'
  post 'stripe_webhook', :controller => 'stripe', :action => 'webhook'
  post 'regenerate_ceph_credentials', :controller => 'support/dashboard', :action => 'regenerate_ceph_credentials'
  post 'regenerate_datacentred_api_credentials', :controller => 'support/dashboard', :action => 'regenerate_datacentred_api_credentials'

  post 'salesforce', :controller => 'salesforce', :action => 'update'

  get 'sign_in', :controller => 'sessions', :action => 'new'

  root :to => 'support/dashboard#index'

  if Rails.env.production?
    get '404', :to => 'errors#page_not_found'
    get '422', :to => 'errors#server_error'
    get '500', :to => 'errors#server_error'
  end

end
