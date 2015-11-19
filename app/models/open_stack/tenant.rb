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

  end
end