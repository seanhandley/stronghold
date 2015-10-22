require 'machinist/active_record'

User.blueprint do
  organization { Organization.make! }
  email      { Faker::Internet.email }
  first_name { Faker::Name.first_name }
  last_name  { Faker::Name.last_name }
  password   { "UpperLower123" }
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
  projects_limit { 100 }
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

module Billing
  Instance.blueprint do
    instance_id { SecureRandom.hex }
    name { Faker::Company.name }
    flavor_id { SecureRandom.hex }
    image_id { SecureRandom.hex }
    tenant_id { SecureRandom.hex }
    arch { 'x86_64' }
  end

  Sync.blueprint {
    completed_at { Time.now }
    started_at { Time.now - 2.minutes }
  }

  InstanceState.blueprint do
    state { 'building' }
    billing_sync { Sync.make! }
    flavor_id { SecureRandom.hex }
    message_id { SecureRandom.hex }
    event_name { 'compute.instance.create.start' }
  end
end