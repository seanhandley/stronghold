module OpenStackObject
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
    def self.object_name     ; :compute  ; end   
  end

  class Image < Base
    def self.collection_name ; :images  ; end
    def self.object_name     ; :compute ; end   
  end

  class Subnet < Base
    def self.collection_name ; :subnets ; end
    def self.object_name     ; :network ; end
  end

  class Resource < Base
    def self.collection_name ; :resources ; end
    def self.object_name     ; :metering  ; end
  end

  class Flavor < Base
    def self.collection_name ; :flavors ; end
    def self.object_name     ; :compute ; end    
  end
end