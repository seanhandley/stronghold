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
        credentials = Fog::Identity.new(OPENSTACK_ARGS).list_ec2_credentials(user.uuid).body['credentials']
        tenants_with_creds = credentials.collect{|c| c['tenant_id']}
        organization.tenants.each do |tenant|
          unless tenants_with_creds.include?(tenant.uuid)
            credential = Fog::Identity.new(OPENSTACK_ARGS).create_ec2_credential(user.uuid, tenant.uuid).body['credential']
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

{"user_id"=>"176e78ee79594334a855c07c0bb45c51", "display_name"=>"codethink_infrastructure", "email"=>"", "suspended"=>0, "max_buckets"=>1000, "subusers"=>[], "keys"=>[{"user"=>"176e78ee79594334a855c07c0bb45c51", "access_key"=>"2edd22eaa460415584f7fd30f2911a64", "secret_key"=>"b6d589a7172149f28422e4806e90aed1"}, {"user"=>"176e78ee79594334a855c07c0bb45c51", "access_key"=>"34da1661ed8a4ed28aae5c9a5df800f3", "secret_key"=>"afd91ef1af23441cb3747840a23494d3"}, {"user"=>"176e78ee79594334a855c07c0bb45c51", "access_key"=>"3842331b60ce45b38f29df1a23fa8fde", "secret_key"=>"c1f1bfd5a2eb4e58b368ebb0e7fe78ae"}, {"user"=>"176e78ee79594334a855c07c0bb45c51", "access_key"=>"412bceded780479fbe0cc61eab27b552", "secret_key"=>"674ced9b99f642b3af4ea394c3f06559"}, {"user"=>"176e78ee79594334a855c07c0bb45c51", "access_key"=>"4268fd3a52214289a31f71d7b543e575", "secret_key"=>"2ea3534187d0415d801bbea50713e227"}, {"user"=>"176e78ee79594334a855c07c0bb45c51", "access_key"=>"7KJKJV2VRV897Z3L8M3M", "secret_key"=>"Iy9kqaA6thrg89LCdS4Nubi1qkPpXkEfq4giNDGH"}, {"user"=>"176e78ee79594334a855c07c0bb45c51", "access_key"=>"872a18c1b9ad45bca10ee2f432548f6b", "secret_key"=>"54fd8a48975a47afb9087895369c8f33"}, {"user"=>"176e78ee79594334a855c07c0bb45c51", "access_key"=>"ebcdaf1b1e5b479884407be1da991de6", "secret_key"=>"97fb61f27a454f2bb5d16ef478d4151e"}, {"user"=>"176e78ee79594334a855c07c0bb45c51", "access_key"=>"f7394888367744839db31f84a94fa854", "secret_key"=>"a8f6750e0a944233a609461ca18d3fb3"}], "swift_keys"=>[], "caps"=>[]}