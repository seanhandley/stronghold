module OpenStackObject
  class Image < Base
    def self.collection_name ; :images  ; end
    def self.object_name     ; :compute ; end   
  end
end
