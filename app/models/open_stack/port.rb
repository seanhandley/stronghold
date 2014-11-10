module OpenStack
  class Port < OpenStackObject::Port
    attributes :name, :network_id, :fixed_ips,
               :mac_address, :status, :admin_state_up,
               :device_owner, :device_id, :tenant_id
  end
end
