namespace :stronghold do
  desc "Sync an organization with Ceph REFERENCE=reference"
  task :sync_with_ceph => :environment do
    if ENV['REFERENCE'].blank?
      puts 'Usage: rake stronghold:sync_with_ceph REFERENCE=xxx'
      exit
    end
    if(organization = Organization.find_by_reference(ENV['REFERENCE']))
      organization.tenants.each do |tenant|
        unless Ceph::User.exists?('uid' => tenant.uuid)
          Ceph::User.create 'uid' => tenant.uuid, 'display-name' => tenant.reference
          puts "Added a Ceph user for tenant #{tenant.reference}"
        end
      end
      organization.users.each do |user|
        credentials = OpenStackConnection.identity.list_ec2_credentials(user.uuid).body['credentials']
        tenants_with_creds = credentials.collect{|c| c['tenant_id']}
        organization.tenants.each do |tenant|
          unless tenants_with_creds.include?(tenant.uuid)
            credential = OpenStackConnection.identity.create_ec2_credential(user.uuid, tenant.uuid).body['credential']
            puts "Created new EC2 credential for tenant #{tenant.reference} for user #{user.name}"
          else
            credential = credentials.select{|c| c['tenant_id'] == tenant.uuid}.first
          end
          keys = Ceph::User.exists?('uid' => tenant.uuid)['keys'].collect{|k| k['access_key']}
          unless keys.include?(credential['access'])
            Ceph::UserKey.create 'uid' => tenant.uuid, 'access-key' => credential['access'], 'secret-key' => credential['secret']
            puts "Added EC2 credential to Ceph for tenant #{tenant.reference} for user #{user.name}"
          end
        end
      end
      puts 'OK'
    else
      puts "Couldn't find an organization with reference #{ENV['REFERENCE']}"
    end
  end
end
