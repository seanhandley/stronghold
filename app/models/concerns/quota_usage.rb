module QuotaUsage

  def used_vcpus
    flavors.sum(&:vcpus)
  end

  def available_vcpus
    quota_set['compute']['cores'].to_i
  end

  def used_ram
    flavors.sum(&:ram)
  end

  def available_ram
    quota_set['compute']['ram'].to_i
  end

  def used_storage
    volumes.sum{|v| v["size"]}
  end

  def available_storage
    quota_set['volume']['gigabytes'].to_i
  end

  def total_used_as_percent
    usage = []
    usage << (used_vcpus.to_f   / available_vcpus.to_f)   if available_vcpus   > 0
    usage << (used_ram.to_f     / available_ram.to_f)     if available_ram     > 0
    usage << (used_storage.to_f / available_storage.to_f) if available_storage > 0
    return 0 if usage.count == 0
    ((usage.sum / usage.count.to_f) * 100).round
  end

  private

  def servers
    LiveCloudResources.servers.select{|server| server["tenant_id"] == uuid}
  end

  def volumes
    LiveCloudResources.volumes.select{|volume| volume["os-vol-tenant-attr:tenant_id"] == uuid}
  end

  def flavors
    servers.map { |s|
      begin
        Billing::InstanceFlavor.find_by_flavor_id(s['flavor']['id'])
      rescue StandardError
        nil
      end
    }.compact
  end
end
