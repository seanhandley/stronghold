module ActiveRecord
  class Base

    def self.authenticates_with_keystone
      define_method :authenticate_openstack do |password|
        begin
          args = OPENSTACK_ARGS.dup
          args.merge!(:openstack_username   => email,
                      :openstack_tenant     => organization.primary_tenant.reference,
                      :openstack_api_key    => password)
          Fog::Identity.new(args).unscoped_token
        rescue Excon::Errors::Unauthorized, NameError => e # Thrown when credentials are invalid
          Rails.logger.info e.inspect
          return false
        end
      end
    end

    def self.syncs_with_keystone(params)
      define_method :create_openstack_object do
        raise ArgumentError, 'Model must define keystone_params' unless respond_to?(:keystone_params)
        o = params[:as].constantize.create keystone_params
        update_column(:uuid, o.id)
      end

      define_method :delete_openstack_object do
        if params[:as] == 'OpenStack::User'
          Fog::Identity.new(OPENSTACK_ARGS).delete_user uuid
        else
          Fog::Identity.new(OPENSTACK_ARGS).delete_tenant uuid
        end
      end

      define_method :update_openstack_object do
        raise ArgumentError, 'Model must define keystone_params' unless respond_to?(:keystone_params)
        params[:as].constantize.find(uuid).update keystone_params
      end

      self.class_eval do
        unless Rails.env.test? || Rails.env.staging?
          after_create(:create_openstack_object)              if params[:actions].include? :create
          before_destroy(:delete_openstack_object)            if params[:actions].include? :destroy
          after_update(:update_openstack_object)              if params[:actions].include? :update
        end
      end
    end

  end
end
