module OpenStack
  class Volume < OpenStackObject::Volume
    attributes :name, :size
  end
end