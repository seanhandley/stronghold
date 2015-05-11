class CreateEC2CredentialsJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    user.organization.tenants.each do |tenant|
      credential = Fog::Identity.new(OPENSTACK_ARGS).create_ec2_credential(user.uuid, tenant.uuid).body['credential']
      Ceph::UserKey.create 'uid' => tenant.uuid, 'access-key' => credential['access'], 'secret-key' => credential['secret']
    end
  end
end