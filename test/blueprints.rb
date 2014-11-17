require 'machinist/active_record'

User.blueprint do
  organization { Organization.make! }
  email      { Faker::Internet.email }
  first_name { Faker::Name.first_name }
  last_name  { Faker::Name.last_name }
  password   { Faker::Internet.password(8) }
end

User.blueprint(:without_password) do
  password { nil }
end

Role.blueprint do
  name        { Faker::Lorem.word }
  permissions { [] }
  power_user  { false }
end

Organization.blueprint do
  name { Faker::Company.name }
end

Invite.blueprint do
  email { Faker::Internet.email }
  organization { Organization.make! }
  roles { [Role.make!] }
end

Invite.blueprint(:power_user) do
  email { Faker::Internet.email }
  organization { Organization.make! }
  power_invite { true }
  roles { [] }
end

Invite.blueprint(:expired) do
  email { Faker::Internet.email }
  organization { Organization.make! }
  roles { [Role.make!] }
  created_at { Time.now - 7.days }
end

Product.blueprint(:compute) do
  id { 1 }
  name { 'Compute' }
end

Product.blueprint(:storage) do
  id { 2 }
  name { 'Storage' }
end

Product.blueprint(:colocation) do
  id { 3 }
  name { 'Colocation' }
end