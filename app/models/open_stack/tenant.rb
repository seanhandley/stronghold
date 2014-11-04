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
      args = {"cores"=>0,"injected_file_content_bytes"=>0, "injected_file_path_bytes"=>0,
        "injected_files"=>0, "instances"=>0, "key_pairs"=>0, "metadata_items"=>0, "ram"=>0}
      Fog::Compute.new(OPENSTACK_ARGS).update_quota id, args
      args = {"volumes"=>0, "snapshots"=>0, "gigabytes" => 0}
      Fog::Volume.new(OPENSTACK_ARGS).update_quota  id, args
      args = {"floatingip"=>0, "security_group_rule"=>0, "security_group"=>0,
              "network"=>0,"port"=>0, "router"=>0, "subnet"=>0}
      Fog::Network.new(OPENSTACK_ARGS).update_quota id, args
      true
    end

  end
end