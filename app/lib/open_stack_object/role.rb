module OpenStackObject
  class Role < Base
    def self.collection_name ; :roles    ; end
    def self.object_name     ; :identity ; end
  end
end
