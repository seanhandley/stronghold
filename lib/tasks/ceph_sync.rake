namespace :stronghold do
  desc "Sync an organization with Ceph REFERENCE=reference"
  task :sync_with_ceph => :environment do
    if ENV['REFERENCE'].blank?
      puts 'Usage: rake stronghold:sync_with_ceph REFERENCE=xxx'
      exit
    end
    if(organization = Organization.find_by_reference(ENV['REFERENCE']))
      organization.projects.each do |project|
        unless Ceph::User.exists?('uid' => project.uuid)
          Ceph::User.create 'uid' => project.uuid, 'display-name' => project.reference
          puts "Added a Ceph user for project #{project.reference}"
        end
      end
      organization.users.each do |user|
        credentials = OpenStackConnection.identity.list_ec2_credentials(user_id: user.uuid).body['credentials']
        projects_with_creds = credentials.collect{|c| c['project_id']}
        organization.projects.each do |project|
          unless projects_with_creds.include?(project.uuid)
            credential = OpenStackConnection.identity.create_ec2_credential(user.uuid, project.uuid).body['credential']
            puts "Created new EC2 credential for project #{project.reference} for user #{user.name}"
          else
            credential = credentials.select{|c| c['project_id'] == project.uuid}.first
          end
          keys = Ceph::User.exists?('uid' => project.uuid)['keys'].collect{|k| k['access_key']}
          unless keys.include?(credential['access'])
            Ceph::UserKey.create 'uid' => project.uuid, 'access-key' => credential['access'], 'secret-key' => credential['secret']
            puts "Added EC2 credential to Ceph for project #{project.reference} for user #{user.name}"
          end
        end
      end
      puts 'OK'
    else
      puts "Couldn't find an organization with reference #{ENV['REFERENCE']}"
    end
  end
end
