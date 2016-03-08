module Billing
  class Sync < ActiveRecord::Base
    self.table_name = "billing_syncs"

    scope :completed, -> { where('completed_at IS NOT NULL') }

    has_many :instance_states, dependent: :destroy
    has_many :volume_states, dependent: :destroy
    has_many :image_states, dependent: :destroy
    has_many :ips, dependent: :destroy
    has_many :load_balancers, dependent: :destroy

    def summary
      "Took #{(completed_at - started_at).round} seconds to sync #{instance_states.count} instance states, #{volume_states.count} volume states, #{ips.count} IP allocations, #{image_states.count} image states, and #{load_balancers.count} load balancers."
    end
  end
end