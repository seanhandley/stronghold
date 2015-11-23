module Billing
  class Usage < ActiveRecord::Base
    self.table_name = "billing_usages"

    belongs_to :organization

    serialize :usage_data, JSON
  end
end