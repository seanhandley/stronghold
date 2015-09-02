class SetDefaultArch < ActiveRecord::Migration
  def change
    change_column :billing_instances, :arch, :string, null: false, default: 'x86_64'
  end
end
