module OpenStackObject
  class Router < Base
    def self.collection_name ; :routers ; end
    def self.object_name     ; :network ; end
  end
end
