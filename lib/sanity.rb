module Sanity
  def self.check
    missing_instances = Billing::Instance.active.reject do |instance|
      live_instances.include? instance.instance_id
    end

    {
      missing_instances: Hash[missing_instances.collect{|i| [i.instance_id, i.name]}]
    }
  end

  def self.notify!(data)
    Mailer.usage_sanity_failures(data).deliver_later
  end

  def self.live_instances
    @@live_instances ||= Fog::Compute.new(OPENSTACK_ARGS).list_servers(:all_tenants => true).body['servers'].collect{|s| s['id']}
  end
end