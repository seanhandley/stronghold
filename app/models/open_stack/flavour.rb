module OpenStack
  class Flavour < OpenStackObject::Flavour
    attributes :name, :ram, :disk, :vcpus, :swap
  end
end