class SetCephAccess < ActiveRecord::Migration
  def change
    Role.all.each{|r| (r.permissions << 'storage.read'; r.save!) unless r.permissions.include?('storage.read') }
  end
end
