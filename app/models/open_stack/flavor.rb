module OpenStack
  class Flavor < OpenStackObject::Flavor
    attributes :name, :ram, :disk, :vcpus, :swap,
               :rxtx_factor, :ephemeral, :is_public,
               :disabled
  end
end
