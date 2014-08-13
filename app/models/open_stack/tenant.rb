module OpenStack
  class Tenant < OpenStackObject::Tenant
    attributes :name, :description, :enabled
  end
end