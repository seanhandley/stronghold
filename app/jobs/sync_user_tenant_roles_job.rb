class SyncUserTenantRolesJob < ActiveJob::Base
  queue_as :default

  def perform(present, user_uuid, tenant_uuid, role_uuid)
    begin
      action = (present ? :create_user_role : :delete_user_role)
      OpenStackConnection.identity.send(action, tenant_uuid, user_uuid, role_uuid)
    rescue Excon::Errors::Conflict, Fog::Identity::OpenStack::NotFound
      # Ignore if this role has already been created/destroyed
    end
  end
end