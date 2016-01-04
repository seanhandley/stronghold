module OpenStackObject
  class User < Base
    def self.collection_name ; :users    ; end
    def self.object_name     ; :identity ; end
  end
end