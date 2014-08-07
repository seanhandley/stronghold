class MakeAuditableIdString < ActiveRecord::Migration
  def change
    change_column :audits, :auditable_id, :string
  end
end
