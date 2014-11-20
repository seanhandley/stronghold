module Billing
  class Sync < ActiveRecord::Base
    self.table_name = "billing_syncs"
  end
end