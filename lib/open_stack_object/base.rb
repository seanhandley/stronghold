require 'fog'

module OpenStackObject

  class Base
    def initialize(obj)
      @obj = obj
    end

    def to_s
      "#<#{self.class.to_s}:#{id} #{@@attributes.collect{|d| "@#{d}=#{send(d.to_sym).inspect}"}.join ', '}>"
    end

    def id
      obj.id
    end

    def inspect
      to_s
    end

    def destroy
      obj.destroy
    end

    class << self

      def all
        conn.send(collection_name).map{|s| new(s) }
      end

      def find_all_by(attribute, value)
        [conn.send(collection_name).find {|s| s.send(attribute.to_sym) == value}].flatten.compact.map do |s|
          new(s)
        end
      end

      def find(id)
        new conn.send(collection_name).get(id)
      end

      def create(args)
        new conn.send(collection_name).create(args)
      end

      private

      def conn
        Rails.cache.fetch(expires_in: 15.minutes) do
          "Fog::#{object_name.to_s.titleize}".constantize.new(OPENSTACK_ARGS)
        end
      end

    end

    private

    def self.default_methods
      [:reload, :persisted?]
    end

    def self.attributes(*args)
      @@attributes = args.each{|a| class_eval{|c| delegate a.to_sym, to: :obj}}
    end

    def self.methods(*args)
      args = [args + default_methods].uniq.flatten.compact
      args.each{|a| class_eval{|c| delegate a.to_sym, to: :obj}}
    end

    def obj
      @obj
    end

    def service_method(&block)
      yield(obj.service)
      self
    rescue Excon::Errors::Conflict => e
      raise OpenStackObject::Error, JSON.parse(e.response.data[:body])['conflictingRequest']['message']
    rescue Fog::Compute::OpenStack::NotFound => e
      raise OpenStackObject::Error, 'Could not find that object'
    end

  end

end