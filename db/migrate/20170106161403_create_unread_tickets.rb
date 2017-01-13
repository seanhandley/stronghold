class CreateUnreadTickets < ActiveRecord::Migration[5.0]
  def change
    create_table :unread_tickets do |t|
      t.string  :update_id
      t.string  :ticket_id
      t.integer :user_id
      t.timestamps
    end
    add_index :unread_tickets, :user_id
  end
end
