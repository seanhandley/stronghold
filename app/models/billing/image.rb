module Billing
  class Image < ActiveRecord::Base
    self.table_name = "billing_images"

    has_many :image_states
  end
end