module Billing
  require_relative 'billing/instances'
  require_relative 'billing/volumes'

  def self.sync!
    ActiveRecord::Base.transaction do
      started_at = Time.zone.now
      from = Billing::Sync.last.started_at
      to   = Time.zone.now
      Billing::Instances.sync!(from, to)
      Billing::Volumes.sync!(from, to)
      Billing::Sync.create started_at: started_at, completed_at: Time.zone.now
    end
  end
end