module OpenStack
  class User < OpenStackObject::User
    attributes :name, :email, :tenant_id, :enabled, :password
  end
end