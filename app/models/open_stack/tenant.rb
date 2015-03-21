module OpenStack
  class Tenant < OpenStackObject::Tenant
    attributes :name, :description, :enabled

    def users
      service_method do |s|
        return s.users(:tenant_id => id).map{|u| User.new(u)}
      end
    end

    def add_user(user, role)
      service_method do |s|
        return s.add_user_to_tenant(self.id, user.id, role.id)
      end
    end

    def remove_user(user, role)
      service_method do |s|
        return s.remove_user_from_tenant(self.id, user.id, role.id)
      end
    end

    def zero_quotas
      args = [
               {"cores"=>0,"injected_file_content_bytes"=>0, "injected_file_path_bytes"=>0,
                "injected_files"=>0, "instances"=>0, "key_pairs"=>0,
                "metadata_items"=>0, "ram"=>0},
      
               {"volumes"=>0, "snapshots"=>0, "gigabytes" => 0},
      
               {"floatingip"=>0, "security_group_rule"=>0, "security_group"=>0,
                "network"=>0,"port"=>0, "router"=>0, "subnet"=>0}
              ]
      
      set_quotas(*args)
    end

    def set_self_service_quotas
      args = [
               {"cores"=>10,"injected_file_content_bytes"=>10240, "injected_file_path_bytes"=>10240,
                "injected_files"=>5, "instances"=>5, "key_pairs"=>10,
                "metadata_items"=>128, "ram"=>51200},
      
               {"volumes"=>5, "snapshots"=>2, "gigabytes" => 100},
      
               {"floatingip"=>1, "security_group_rule"=>100, "security_group"=>10,
                "network"=>5,"port"=>20, "router"=>5, "subnet"=>5}
              ]
      
      set_quotas(*args)  
    end

    private

    def set_quotas(compute, volume, network)
      Fog::Compute.new(OPENSTACK_ARGS).update_quota id, compute
      Fog::Volume.new(OPENSTACK_ARGS).update_quota  id, volume
      Fog::Network.new(OPENSTACK_ARGS).update_quota id, network
      true
    end

  end
end