class CheckCephAccessJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    if User::Ability.new(user).can?(:read, :storage)
      user.organization.tenants.each do |tenant|
        begin
          Ceph::UserKey.create 'uid' => tenant.uuid,
                               'access-key' => user.ec2_credentials['access'],
                               'secret-key' => user.ec2_credentials['secret']
        rescue Net::HTTPError => e
          Honeybadger.notify(e)
        end
      end
    else
      user.organization.tenants.each do |tenant|
        begin
          Ceph::UserKey.delete 'access-key' => user.ec2_credentials['access']
        rescue Net::HTTPError => e
          Honeybadger.notify(e) unless e.message.include? 'AccessDenied'
        end
      end
    end
  end
end