class TerminateAccountJob < ActiveJob::Base
  include OffboardingHelper
  queue_as :default

  def perform(tenant, creds)
    offboard(tenant, creds)
    tenant.organization.users.each do |user|
      begin
        Ceph::User.destroy('uid' => user.uuid, 'display-name' => user.name)
      rescue Net::HTTPError => e
        Honeybadger.notify(e)
      end
    end
  end
end