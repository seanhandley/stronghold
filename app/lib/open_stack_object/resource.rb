module OpenStackObject
  class Resource < Base
    def self.collection_name ; :resources ; end
    def self.object_name     ; :metering  ; end
  end
end
