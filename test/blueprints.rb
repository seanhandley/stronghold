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

Tenant.blueprint do
  organization { Organization.make! }
  name { Faker::Company.name }
  uuid { '1c483a77bbe44afcaf3a1d098a1a897f' }
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
  created_at { Time.now - 14.days }
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

Voucher.blueprint do
  name { "Free 1 Month Trial" }
  description { "First month is free" }
  code { "FREEDOM" }
  duration { 1 }
  discount_percent { 100 }
  expires_at { Time.now + 1.year }
end
