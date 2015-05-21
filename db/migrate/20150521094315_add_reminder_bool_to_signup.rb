class AddReminderBoolToSignup < ActiveRecord::Migration
  def change
    add_column :customer_signups, :reminder_sent, :boolean, default: false, null: false
  end
end
