class AddRemoteMessageIdField < ActiveRecord::Migration
  def change
    add_column :invites, :remote_message_id, :string
  end
end
