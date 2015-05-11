class SetSelfServiceDefaults < ActiveRecord::Migration
  def change
    Organization.all.each{|o| o.update_attributes self_service: false }
    Role.all.each{|r| (r.permissions << 'cloud.read'; r.save!) unless r.permissions.include?('cloud.read') }
  end
end
