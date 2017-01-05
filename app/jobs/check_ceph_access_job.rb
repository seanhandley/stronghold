class CheckCephAccessJob < ApplicationJob
  queue_as :default

  def perform(user)
    if User::Ability.new(user).can?(:read, :storage)
      begin
        Ceph::UserKey.create 'uid' => user.organization.primary_project.uuid,
                             'access-key' => user.ec2_credentials['access'],
                             'secret-key' => user.ec2_credentials['secret'] if user.ec2_credentials
      rescue Net::HTTPError => e
        unless ['BucketAlreadyExists', 'KeyExists'].include? e.message
          Honeybadger.notify(e)
          raise
        end
      end
    else
      user.organization.projects.each do |project|
        begin
          Ceph::UserKey.destroy 'access-key' => user.ec2_credentials['access'] if user.ec2_credentials
        rescue Net::HTTPError => e
          unless ['AccessDenied', 'InvalidAccessKeyId'].include? e.message
            Honeybadger.notify(e) 
            raise
          end
        end
      end
    end
  end
end