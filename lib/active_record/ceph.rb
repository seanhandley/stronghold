module ActiveRecord
  class Base
    def self.syncs_with_ceph(params)
      define_method :create_ceph_object do
        raise ArgumentError, 'Model must define ceph_params' unless respond_to?(:ceph_params)
        params[:as].constantize.create ceph_params
      rescue Net::HTTPError => e
        Honeybadger.notify(e)
      end

      define_method :delete_ceph_object do
        params[:as].constantize.destroy ceph_params
      rescue Net::HTTPError => e
        Honeybadger.notify(e)
      end

      self.class_eval do
        unless Rails.env.test? || Rails.env.staging?
          after_create(:create_ceph_object)             if params[:actions].include? :create
          after_destroy(:delete_ceph_object)            if params[:actions].include? :destroy
        end
      end
    end
  end
end