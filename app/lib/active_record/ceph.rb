module ActiveRecord
  module Ceph
    def syncs_with_ceph(params)
      define_method :create_ceph_object do
        begin
          raise ArgumentError, 'Model must define ceph_params' unless respond_to?(:ceph_params)
          params[:as].constantize.create ceph_params
        rescue Net::HTTPError => e
          Honeybadger.notify(e)
        end
      end

      define_method :delete_ceph_object do
        begin
          params[:as].constantize.destroy ceph_params.merge('purge-data' => true)
        rescue Net::HTTPError => e
          Honeybadger.notify(e)
        end
      end

      self.class_eval do
        unless Rails.env.test?
          after_create(:create_ceph_object)             if params[:actions].include? :create
          after_destroy(:delete_ceph_object)            if params[:actions].include? :destroy
        end
      end
    end
  end
end
