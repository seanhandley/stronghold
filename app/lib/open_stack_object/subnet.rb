module OpenStackObject
  class Subnet < Base
    def self.collection_name ; :subnets ; end
    def self.object_name     ; :network ; end
  end
end
