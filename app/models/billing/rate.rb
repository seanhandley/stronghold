module Billing
  class Rate < ActiveRecord::Base
    self.table_name = "billing_rates"

    belongs_to :instance_flavor, :class_name => "Billing::InstanceFlavor",
               :primary_key => 'id', :foreign_key => 'flavor_id'
  
    validates :rate, presence: true, allow_blank: false
    validates :rate, numericality: { greater_than: 0, less_than_or_equal_to: 100 }

    default_scope -> { order('flavor_id', 'arch')}

    scope :visible, -> { where(show: true)}

    scope :ordered_by_name_and_arch, -> { visible.sort{|x,y| x.instance_flavor.name <=> y.instance_flavor.name}}
  end
end