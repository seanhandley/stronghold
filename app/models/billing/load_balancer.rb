module Billing
  class LoadBalancer < ActiveRecord::Base
    self.table_name = "billing_load_balancers"

    validates :lb_id, uniqueness: true
    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'

    def status
      return 'terminated' if terminated_at
      if active_load_balancers.include?(lb_id)
        'active'
      else
        update_columns terminated_at: Time.now
        'terminated'
      end
    end

    private

    def active_load_balancers
      Rails.cache.fetch("active_load_balancers", expires: 10.minutes) do
        OpenStackConnection.network.list_lb_pools.body['pools'].map{|lb| lb['id']}
      end
    end
  end
end
