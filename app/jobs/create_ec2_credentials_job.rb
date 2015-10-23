class CreateEC2CredentialsJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    tenant = user.organization.primary_tenant
    OpenStackConnection.identity.create_ec2_credential(user.uuid, tenant.uuid).body['credential']
    CheckCephAccessJob.perform_later(user)
  end
end