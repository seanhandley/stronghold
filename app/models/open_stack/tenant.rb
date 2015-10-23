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
      set_quotas(StartingQuota['zero'])
    end    

    def set_self_service_quotas(quota)
      OpenStack::Tenant.set_self_service_quotas id, quota
    end

    def self.set_self_service_quotas(id, quota)
      set_quotas(id, StartingQuota[quota])
    end

    def set_custom_quotas(quota)
      OpenStack::Tenant.set_custom_quotas id, quota
    end

    def self.set_custom_quotas(id, quota)
      set_quotas(id, quota)
    end

    private

    def set_quotas(quota)
      OpenStack::Tenant.set_quotas(id, quota)
    end

    def self.set_quotas(id, quota)
      return false unless quota
      OpenStackConnection.compute.update_quota id, quota['compute']
      OpenStackConnection.volume.update_quota  id, quota['volume']
      OpenStackConnection.network.update_quota id, quota['network']
      true
    end

  end
end