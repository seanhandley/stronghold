class AllowStringIds < ActiveRecord::Migration
  def change
    change_column :espinita_audits, :auditable_id, :string
  end
end
