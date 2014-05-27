module OpenStack
  class Flavor < OpenStackObject::Flavor
    attributes :name, :ram, :disk, :vcpus, :swap
  end
end