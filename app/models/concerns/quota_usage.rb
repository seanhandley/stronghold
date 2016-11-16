module QuotaUsage

  def used_vcpus
    flavors.map(&:vcpus).sum
  end

  def available_vcpus
    limit = quota_set['compute']['cores'].to_i
    limit - used_vcpus
  end

  def used_ram
    flavors.map(&:ram).sum
  end

  def available_ram
    limit = quota_set['compute']['memory'].to_i
    limit - used_ram
  end

  def used_storage
    LiveCloudResourcess.volumes.map{|s| s["size"] }.sum
  end

  def available_storage
    limit = quota_set['volume']['storage'].to_i
    limit - used_storage
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
    servers.select{|server| server.project_id == uuid}
  end

  def flavors
    servers.map{|s| Billing::InstanceFlavor.find_by_flavor_id(s['flavor']['id']) rescue nil}.compact
  end
end
