class Timestamps < ActiveRecord::Migration
  def change
    add_timestamps(:tenants)
  end
end
