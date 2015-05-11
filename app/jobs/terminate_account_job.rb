class TerminateAccountJob < ActiveJob::Base
  include OffboardingHelper
  queue_as :default

  def perform(tenant)
    offboard(tenant)
    tenant.organization.users.each do |user|
      begin
        Ceph::User.destroy('uid' => user.uuid, 'display-name' => user.name)
      rescue Net::HTTPError => e
        notify_honeybadger(e)
      end
    end
  end
end