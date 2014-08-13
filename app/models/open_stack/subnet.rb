module OpenStack
  class Subnet < OpenStackObject::Subnet
    attributes :name, :cidr, :gateway_ip, :network_id, :ip_version,
               :allocation_pools, :dns_nameservers, :host_routes,
               :enable_dhcp, :tenant_id
  end
end
