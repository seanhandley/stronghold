module Billing
  class InstanceState < ActiveRecord::Base
    self.table_name = "billing_instance_states"

    belongs_to :billing_instance, :class_name => "Billing::Instance", :foreign_key => 'instance_id'
    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'

    belongs_to :instance_flavor, :class_name => "Billing::InstanceFlavor",
           :primary_key => 'flavor_id', :foreign_key => 'flavor_id'

    def rate(arch)
      Rails.logger.debug '*' * 10
      flavor = instance_flavor ? instance_flavor : Billing::InstanceFlavor.find(billing_instance.flavor_id)
      Rails.logger.debug flavor.inspect
      Rails.logger.debug flavor.rates.inspect
      Rails.logger.debug arch
      Rails.logger.debug '*' * 10
      flavor.rates.where(arch: arch).first.rate rescue nil
    end

  end
end