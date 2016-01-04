module OpenStackObject
  class Flavor < Base
    def self.collection_name ; :flavors ; end
    def self.object_name     ; :compute ; end    
  end
end