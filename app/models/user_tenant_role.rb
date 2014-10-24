class UserTenantRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :tenant

  after_save :create_tenant_role, on: :create
  after_destroy :destroy_tenant_role

  private

  def create_tenant_role
    role, user, tenant = os_objects
    tenant.add_user(user, role)
  end

  def destroy_tenant_role
    role, user, tenant = os_objects
    tenant.remove_user(user, role)   
  end

  def os_objects
    [OpenStack::Role.find(role_uuid),
     OpenStack::User.find(user.uuid),
     OpenStack::Tenant.find(tenant.uuid)]
  end

end