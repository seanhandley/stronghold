module Billing
  class Ip < ActiveRecord::Base
    self.table_name = "billing_ips"

    validates :address, :tenant_id, presence: true

    has_many :ip_states

    scope :active, -> { where(active: true) }
  end
end