# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Product.find_or_create_by name: 'Compute'
Product.find_or_create_by name: 'Storage'
Product.find_or_create_by name: 'Colocation'

# Noops
Organization.redefine_method :create_salesforce_object do ; end
Organization.redefine_method :update_salesforce_object do ; end
Project.redefine_method      :create_openstack_object  do ; end
Project.redefine_method      :create_ceph_object       do ; end
Project.redefine_method      :delete_ceph_object       do ; end
User.redefine_method         :create_openstack_object  do ; end
User.redefine_method         :update_password          do ; end
User.redefine_method         :generate_ec2_credentials do ; end
User.redefine_method         :subscribe_to_status_io   do ; end

if ['test','development'].include?(Rails.env)
  organization = Organization.create(name: 'DataCentred', reference: STAFF_REFERENCE, self_service: false)
  project = Project.create(name: 'datacentred', uuid: '612bfb90f93c4b6e9ba515d51bb16022', organization: organization)
  organization.primary_project_id = project.id
  organization.save!

  users = [
    {id: 1, email: 'sean.handley@datacentred.co.uk', first_name: 'Sean', last_name: 'Handley', uuid: '55a927f50f304db3af1306eacbafda32'},
    {id: 2, email: 'eugenia.grieff@datacentred.co.uk', first_name: 'Eugenia', last_name: 'Grieff', uuid: '06eacbafda355a927f50f304db3af132'}
  ]
  role = Role.create(organization: organization, name: 'Administrator', permissions: Permissions.user.keys, power_user: true)

  users.each do |u|
    user = organization.users.create!(u.merge(password: 'm8PuKbdwgP2VzQ'))
    ou = OrganizationUser.find_by(organization: organization, user: user)
    ou.roles << role
    ou.save!
  end

  organization.products << Product.all

elsif Rails.env == 'acceptance'
  rand = (0...8).map { ('a'..'z').to_a[rand(26)] }.join.downcase
  cg = CustomerGenerator.new(organization_name: rand, email: "#{rand}@test.com",
    extra_projects: "", organization: { product_ids: Product.all.map{|p| p.id.to_s}})
  cg.generate!
  rg = RegistrationGenerator.new(Invite.first, password: '12345678')
  rg.generate!
  STAFF_REFERENCE = Organization.first.reference
end
