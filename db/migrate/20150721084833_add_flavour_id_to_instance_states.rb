class AddFlavourIdToInstanceStates < ActiveRecord::Migration
  def change
    add_column :billing_instance_states, :flavor_id, :string
  end
end
