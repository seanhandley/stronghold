module Billing
  class Image < ActiveRecord::Base
    self.table_name = "billing_images"

    validates :image_id, uniqueness: true

    has_many :image_states
  end
end