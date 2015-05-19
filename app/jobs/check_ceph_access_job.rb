class CheckCephAccessJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    if User::Ability.new(user).can?(:read, :storage)
      user.organization.tenants.each do |tenant|
        begin
          Ceph::UserKey.create 'uid' => tenant.uuid,
                               'access-key' => user.ec2_credentials(tenant.uuid)['access'],
                               'secret-key' => user.ec2_credentials(tenant.uuid)['secret'] if user.ec2_credentials(tenant.uuid)
        rescue Net::HTTPError => e
          Honeybadger.notify(e)
        end
      end
    else
      user.organization.tenants.each do |tenant|
        begin
          Ceph::UserKey.destroy 'access-key' => user.ec2_credentials(tenant.uuid)['access'] if user.ec2_credentials(tenant.uuid)
        rescue Net::HTTPError => e
          Honeybadger.notify(e) unless e.message.include? 'AccessDenied'
        end
      end
    end
  end
end