class AddLastAlertedForLowQuotasAtToOrganizations < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :last_alerted_for_low_quotas_at, :datetime
  end
end
