module OpenStackObject
  class Server < Base
    def self.collection_name ; :servers ; end
    def self.object_name     ; :compute ; end
  end
end
