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

    class << self

      def all
        conn.send(collection_name).map{|s| new(s) }
      end

      def find_all_by(attribute, value)
        [conn.send(collection_name).find {|s| s.send(attribute.to_sym) == value}].flatten.compact.map do |s|
          new(s)
        end
      end

      private

      def conn
        @@c ||= "Fog::#{object_name.to_s.titleize}".constantize.new(OPENSTACK_ARGS)
      end

    end

    private

    def self.attributes(*args)
      @@attributes = args.each{|a| class_eval{|c| delegate a.to_sym, to: :obj}}
    end

    def self.methods(*args)
      args.each{|a| class_eval{|c| delegate a.to_sym, to: :obj}}
    end

    def obj
      @obj
    end

  end

  class Server < Base
    def self.collection_name ; :servers ; end
    def self.object_name     ; :compute ; end
  end

  class Tenant < Base
    def self.collection_name ; :tenants  ; end
    def self.object_name     ; :identity ; end
  end

  class User < Base
    def self.collection_name ; :users    ; end
    def self.object_name     ; :identity ; end
  end

  class Volume < Base
    def self.collection_name ; :volumes  ; end
    def self.object_name     ; :volume   ; end   
  end

  class Image < Base
    def self.collection_name ; :images  ; end
    def self.object_name     ; :image   ; end   
  end

  class Subnet < Base
    def self.collection_name ; :subnets ; end
    def self.object_name     ; :network ; end
  end

  class Resource < Base
    def self.collection_name ; :resources ; end
    def self.object_name     ; :metering ; end
  end

end