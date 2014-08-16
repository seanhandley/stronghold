class AddReferenceFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :openstack_id, :string
  end
end
