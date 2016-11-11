module QuotaUsage

  def used_vcpus
    
  end

  def available_vcpus
    100
  end

  def used_ram
    
  end

  def available_ram
    512_000
  end

  def used_storage
    
  end

  def available_storage
    10240
  end

  def total_used_as_percent
    usage = []
    usage << (used_vcpus.to_f   / available_vcpus.to_f)   if available_vcpus   > 0
    usage << (used_ram.to_f     / available_ram.to_f)     if available_ram     > 0
    usage << (used_storage.to_f / available_storage.to_f) if available_storage > 0
    return 0 if usage.count == 0
    ((usage.sum / usage.count.to_f) * 100).round
  end
end