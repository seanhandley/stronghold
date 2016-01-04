class CreateEC2CredentialsJob < ApplicationJob
  queue_as :default

  def perform(user)
    project = user.organization.primary_project
    OpenStackConnection.identity.create_os_credential(blob: blob.to_json, type: 'ec2', user_id: user.uuid, project_id: project.uuid).body['credential']
    CheckCephAccessJob.perform_later(user)
  end

  def blob
     {
       "access" => SecureRandom.hex,
       "secret" => SecureRandom.hex
     }
  end
end