module OpenStack
  class Router < OpenStackObject::Router
    attributes :name, :admin_state_up, :tenant_id,
               :external_gateway_info, :status
  end
end
