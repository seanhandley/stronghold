module OpenStack
  class Network < OpenStackObject::Network
    attributes :name, :shared, :admin_state_up,
               :tenant_id, :router_external, :subnets,
               :network_id

    def subnets
      service_method do |s|
        return s.subnets.select {|s| s.network_id == id }.map do |sn|
          OpenStack::Subnet.new(sn)
        end
      end
    end
  end
end
