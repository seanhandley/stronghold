module ActiveRecord
  class Base

    def self.authenticates_with_keystone
      define_method :authenticate do |password|
        begin
          args = OPENSTACK_ARGS.dup
          args.merge!(:openstack_username   => email,
                      :openstack_tenant     => organization.primary_tenant.reference,
                      :openstack_api_key    => password)
          Fog::Identity.new(args).unscoped_token
        rescue NameError => e # Thrown when credentials are invalid
          Rails.logger.info e.inspect
          return false
        end
      end
    end

    def self.syncs_with_keystone(params)
      define_method :create_object do
        raise ArgumentError, 'Model must define keystone_params' unless respond_to?(:keystone_params)
        o = params[:as].constantize.create keystone_params
        update_column(:uuid, o.id)
      end

      define_method :delete_object do
        params[:as].constantize.find(uuid).destroy
      end

      define_method :update_object do
        raise ArgumentError, 'Model must define keystone_params' unless respond_to?(:keystone_params)
        params[:as].constantize.find(uuid).update keystone_params
      end

      self.class_eval do
        unless Rails.env.test?
          after_create(:create_object)             if params[:actions].include? :create
          after_destroy(:delete_object)            if params[:actions].include? :destroy
          after_update(:update_object)             if params[:actions].include? :update
        end
      end
    end

  end
end
