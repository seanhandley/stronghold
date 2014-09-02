# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

organization = Organization.create(name: 'BBC')

user = organization.users.create(email: 'support@datacentred.co.uk', password: 'llama123',
            first_name: 'Testy', last_name: 'Tester')

role = Role.create(organization: organization, name: 'Administrator', permissions: Permissions.user.keys, power_user: true)

user.roles << role
user.save!