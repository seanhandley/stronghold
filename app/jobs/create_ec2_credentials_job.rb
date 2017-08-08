class CreateEC2CredentialsJob < ApplicationJob
  queue_as :default

  def perform(organization_user)
    project = organization_user.organization.primary_project
    OpenStackConnection.identity.create_os_credential(blob: blob.to_json, type: 'ec2', user_id: organization_user.user.uuid, project_id: project.uuid).body['credential']
    CheckCephAccessJob.perform_later(organization_user)
  end

  def blob
     {
       "access" => SecureRandom.hex,
       "secret" => SecureRandom.hex
     }
  end
end