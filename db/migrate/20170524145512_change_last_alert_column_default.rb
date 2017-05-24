class ChangeLastAlertColumnDefault < ActiveRecord::Migration[5.0]
  def change
    change_column_default :organizations, :last_alerted_for_low_quotas_at, "1970-01-01 01:00:00"
  end
end
