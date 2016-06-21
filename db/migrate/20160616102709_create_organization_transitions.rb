class CreateOrganizationTransitions < ActiveRecord::Migration
  def change
    create_table :organization_transitions do |t|
      t.string :to_state, null: false
      t.text :metadata
      t.integer :sort_key, null: false
      t.integer :organization_id, null: false
      t.boolean :most_recent
      t.timestamps null: false
    end

    add_index(:organization_transitions,
              [:organization_id, :sort_key],
              unique: true,
              name: "index_organization_transitions_parent_sort")
    add_index(:organization_transitions,
              [:organization_id, :most_recent],
              unique: true,
              
              name: "index_organization_transitions_parent_most_recent")
  end
end
