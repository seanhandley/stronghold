require 'machinist/active_record'

User.blueprint do
  email      { Faker::Internet.email }
  first_name { Faker::Name.first_name }
  last_name  { Faker::Name.last_name }
  password   { Faker::Internet.password(8) }
end

User.blueprint(:without_password) do
  password { nil }
end