module ActiveRecord
  module Openstack
    def authenticates_with_keystone
      define_method :authenticate_openstack do |password|
        return true
        begin
          args = OPENSTACK_ARGS.dup
          args.merge!(:openstack_username         => email,
                      :openstack_project_name     => organization.primary_project.reference,
                      :openstack_api_key          => password)
          Fog::Identity.new(args).unscoped_token
        rescue Excon::Errors::Unauthorized, NameError => e # Thrown when credentials are invalid
          Rails.logger.info e.inspect
          return false
        rescue Excon::Errors::Timeout => e
          Honeybadger.notify(e)
          return false
        end
      end
    end

    def syncs_with_keystone(params)
      define_method :create_openstack_object do
        begin
          raise ArgumentError, 'Model must define keystone_params' unless respond_to?(:keystone_params)
          o = params[:as].constantize.create keystone_params
          self.uuid = o.id
        rescue Excon::Errors::Conflict
          errors.add(:name, "has already been taken")
          return false
        end
      end

      define_method :delete_openstack_object do
        if params[:as] == 'OpenStack::User'
          OpenStackConnection.identity.delete_user uuid
        else
          OpenStackConnection.identity.delete_project uuid
        end
      end

      define_method :update_openstack_object do
        raise ArgumentError, 'Model must define keystone_params' unless respond_to?(:keystone_params)
        params[:as].constantize.find(uuid).update keystone_params
      end

      define_method :can_sync_with_openstack do
        begin
          OpenStackConnection.identity.list_roles
        rescue Excon::Errors::Timeout
          errors.add(:base, "Sorry - we couldn't sync that with OpenStack. Please try later.")
        end
      end

      self.class_eval do
        unless Rails.env.test?
          validate(:can_sync_with_openstack)
          before_create(:create_openstack_object)             if params[:actions].include? :create
          before_destroy(:delete_openstack_object)            if params[:actions].include? :destroy
          after_update(:update_openstack_object)              if params[:actions].include? :update
        end
      end
    end
  end
end
