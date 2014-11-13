# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if ['test','development'].include?(Rails.env)
  Tenant.skip_callback(:create, :after, :after_action)
  User.skip_callback(:create, :after, :after_action)

  organization = Organization.create(name: 'DataCentred', reference: STAFF_REFERENCE)
  tenant = Tenant.create(name: 'datacentred', uuid: 'ed4431814d0a40dc8f10f5ac046267e9', organization: organization)
  organization.update_column(:primary_tenant_id, tenant.id)

  users = [{id: 1, email: 'sean.handley@datacentred.co.uk', first_name: 'Sean', last_name: 'Handley', uuid: '1677558442d74ee69f12d04fbadf7c39'},
           {id: 5, email: 'dariush.marsh@datacentred.co.uk', first_name: 'Dariush', last_name: 'Marsh', uuid: 'ddf34f7dcde2431f94ad8b973ced9e9b'},
           {id: 7, email: 'rob.greenwood@datacentred.co.uk', first_name: 'Rob', last_name: 'Greenwood', uuid: '2ef04671b17041f5bf2c35f1f72ca306'},
           {id: 9, email: 'max.siegieda@datacentred.co.uk', first_name: 'Max', last_name: 'Siegieda', uuid: '163a91bcf6fa40b198e537bbf89902c5'},
           {id: 10, email: 'nick.jones@datacentred.co.uk', first_name: 'Nick', last_name: 'Jones', uuid: 'd1a60c7b4bbc427e8f2c3f99d0c2e6d2'},
           {id: 35, email: 'matt.jarvis@datacentred.co.uk', first_name: 'Matt', last_name: 'Jarvis', uuid: '7c66e34d7df947c0b1a3e2532732b73b'}]

  role = Role.create(organization: organization, name: 'Administrator', permissions: Permissions.user.keys, power_user: true)

  users.each do |u|
    user = organization.users.create(u.merge(password: '12345678'))
    user.roles << role
    user.save!
  end

  Product.create! name: 'Compute'
  Product.create! name: 'Storage'
  Product.create! name: 'Colocation'
  
end