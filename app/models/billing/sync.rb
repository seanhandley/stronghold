module Billing
  class Sync < ActiveRecord::Base
    self.table_name = "billing_syncs"

    scope :completed, -> { where('completed_at IS NOT NULL') }

    has_many :instance_states, dependent: :destroy
    has_many :volume_states, dependent: :destroy
    has_many :ip_states, dependent: :destroy
    has_many :image_states, dependent: :destroy

    def summary
      "#{instance_states.count} instance state changes. #{volume_states.count} volume state changes. #{ip_states.count} IP state change. #{image_states.count} image state changes."
    end
  end
end