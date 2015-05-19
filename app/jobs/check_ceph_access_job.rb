class CheckCephAccessJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    if User::Ability.new(user).can?(:read, :storage)
      user.organization.tenants.each do |tenant|
        begin
          Ceph::UserKey.create 'uid' => tenant.uuid,
                               'access-key' => user.ec2_credentials['access'],
                               'secret-key' => user.ec2_credentials['secret'] if user.ec2_credentials
        rescue Net::HTTPError => e
          Honeybadger.notify(e)
        end
      end
    else
      user.organization.tenants.each do |tenant|
        begin
          Ceph::UserKey.destroy 'access-key' => user.ec2_credentials['access'] if user.ec2_credentials
        rescue Net::HTTPError => e
          Honeybadger.notify(e) unless e.message.include? 'AccessDenied'
        end
      end
    end
  end
end