module OpenStack
  class Network < OpenStackObject::Network
    attributes :name, :shared, :admin_state_up,
               :tenant_id, :router_external
  end
end
