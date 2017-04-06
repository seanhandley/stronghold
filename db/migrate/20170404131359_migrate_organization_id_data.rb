class MigrateOrganizationIdData < ActiveRecord::Migration[5.0]
  User.all.each{|u| u.update_attributes organizations: [Organization.find_by_id(u.organization_id)].compact }
end
