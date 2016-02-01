class SyncUserProjectRolesJob < ActiveJob::Base
  queue_as :default

  def perform(present, user_uuid, project_uuid, role_uuid)
    begin
      action = (present ? :grant_project_user_role : :revoke_project_user_role)
      OpenStackConnection.identity.send(action, project_uuid, user_uuid, role_uuid)
    rescue Excon::Errors::Conflict, Fog::Identity::OpenStack::NotFound
      # Ignore if this role has already been created/destroyed
    end
  end
end