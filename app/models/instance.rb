require 'fog'

class Instance < OpenStackObject::Compute

  attributes :name, :state

end