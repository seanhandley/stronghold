class DropEspinitaAudits < ActiveRecord::Migration
  def change
    drop_table :espinita_audits
  end
end
