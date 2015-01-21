module OpenStack
  class User < OpenStackObject::User
    attributes :name, :email, :tenant_id, :enabled, :password

    def roles_for(tenant)
      service_method do |s|
        return s.list_roles_for_user_on_tenant(tenant.id, id).body['roles'].map{|u| Role.new(u)}
      end    
    end

    def self.update_password(uuid, password)
      unless Rails.env.test?
        conn = Fog::Identity.new(OPENSTACK_ARGS)
        u = conn.users.select {|u| u.id == uuid}.first
        u.update_password(password)
      end
    end
  end
end