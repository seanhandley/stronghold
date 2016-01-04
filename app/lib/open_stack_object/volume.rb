module OpenStackObject
  class Volume < Base
    def self.collection_name ; :volumes  ; end
    def self.object_name     ; :compute  ; end   
  end
end
