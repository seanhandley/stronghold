class UserTenantRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :tenant

  validates :role_uuid, presence: true

  after_save :create_tenant_role, on: :create
  after_destroy :destroy_tenant_role

  def self.required_role_ids
    ["heat_stack_owner", "_member_", "object-store"].collect do |name|
      os_roles.select{|r| r['name'].include? name}.collect{|r| r['id']}
    end.flatten.compact
  end

  private

  def create_tenant_role
    SyncUserTenantRolesJob.perform_later(true, *os_objects)
  end

  def destroy_tenant_role
    SyncUserTenantRolesJob.perform_later(false, *os_objects)
  end

  def os_objects
    [user.uuid, tenant.uuid, role_uuid]
  end

  def self.os_roles
    Rails.cache.fetch("required_tenant_roles", expires_in: 1.day.from_now) do
      OpenStackConnection.identity.list_roles.body['roles']
    end
  end

end