class CheckCephAccessJob < ApplicationJob
  queue_as :default

  def perform(organization_user)
    if OrganizationUser::Ability.new(organization_user).can?(:read, :storage)
      begin
        Ceph::UserKey.create 'uid' => organization_user.organization.primary_project.uuid,
                             'access-key' => organization_user.ec2_credentials['access'],
                             'secret-key' => organization_user.ec2_credentials['secret'] if organization_user.ec2_credentials
      rescue Net::HTTPError => e
        unless ['BucketAlreadyExists', 'KeyExists'].include? e.message
          Honeybadger.notify(e)
          raise
        end
      end
    else
      organization_user.organization.projects.each do |project|
        begin
          Ceph::UserKey.destroy 'access-key' => organization_user.ec2_credentials['access'] if organization_user.ec2_credentials
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