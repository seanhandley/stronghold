module Billing
  class Image < ActiveRecord::Base
    self.table_name = "billing_images"

    validates :image_id, uniqueness: true

    has_many :image_states
    
    scope :active, -> { all.select(&:active?) }

    def active?
      latest_state = image_states.order('recorded_at').last
      latest_state ? Billing::Images.billable?(latest_state.state) : true
    end
  end
end