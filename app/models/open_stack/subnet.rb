module OpenStack
  class Subnet < OpenStackObject::Subnet
    attributes :name, :cidr, :gateway_ip
  end
end