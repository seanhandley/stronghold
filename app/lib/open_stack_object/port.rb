module OpenStackObject
  class Port < Base
    def self.collection_name ; :ports    ; end
    def self.object_name     ; :network  ; end
  end
end
