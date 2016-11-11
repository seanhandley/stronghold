module QuotaUsage

  def get_data
    ogd = OrganizationGraphDecorator.new(@organization)
    ogd.graph_data
  end

  def used_vcpus
    get_data[:compute][:cores][:used]
  end

  def available_vcpus
    get_data[:compute][:cores][:available]
    # 100
  end

  def used_ram
    get_data[:compute][:memory][:used]
  end

  def available_ram
    get_data[:compute][:memory][:available]
    # 512_000
  end

  def used_storage
    get_data[:volume][:storage][:used]
  end

  def available_storage
    get_data[:volume][:storage][:available]
    # 10240
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
