module ActiveRecord
  class Base
    def self.syncs_with_ceph(params)
      define_method :create_ceph_object do
        raise ArgumentError, 'Model must define ceph_params' unless respond_to?(:ceph_params)
        params[:as].constantize.create ceph_params
      end

      define_method :delete_ceph_object do
        params[:as].constantize.destroy ceph_params
      end

      self.class_eval do
        if Rails.env.production?
          after_create(:create_ceph_object)             if params[:actions].include? :create
          after_destroy(:delete_ceph_object)            if params[:actions].include? :destroy
        end
      end
    end
  end
end