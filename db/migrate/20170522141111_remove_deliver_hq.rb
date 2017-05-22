class RemoveDeliverHq < ActiveRecord::Migration[5.0]
  def change
    remove_column :invites, :remote_message_id
  end
end
