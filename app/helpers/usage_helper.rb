module UsageHelper
  include ActionView::Helpers::FormOptionsHelper

  def usages_for_select(organization)
    organization.started_paying_at
    entries = billing_range(organization).select{|date| date.day == 1}.map do |date|
      {year: date.year, month: date.month}
    end

    coll = entries.collect do |entry|
      ["#{Date::MONTHNAMES[entry[:month]]} #{entry[:year]}", support_usage_path(entry)]
    end

    options_for_select(coll, selected: support_usage_path(month: params[:month], year: params[:year]))
  end

  def billing_range(organization)
    (organization.created_at.beginning_of_month.to_date..Date.today.end_of_month).to_a.reverse
  end

  def get_time_period(year, month)
    if year && month
      month = Time.parse("#{year}-#{month}-01 00:00:00").end_of_month
      if month > current_organization.created_at && month < Time.zone.now.end_of_month
        @from_date = month.beginning_of_month
        @to_date = (month.end_of_month < Time.zone.now) ? month.end_of_month : Time.zone.now
      else
        @from_date = Time.zone.now.beginning_of_month
        @to_date = Time.zone.now
      end
    else
      @from_date = Time.zone.now.beginning_of_month
      @to_date = Time.zone.now
    end
    [@from_date, @to_date]
  end

  def architecture_human_name(arch)
    return '-' if arch.blank?
    case arch.downcase
    when 'aarch64'
      'ARM'
    when 'x86_64'
      'Intel x86'
    else
      arch
    end
  end

  def state_with_icon(state)
    case state.downcase
    when 'active'
      "<i class='fa fa-play text-success'></i> Active".html_safe
    when 'stopped'
      "<i class='fa fa-pause'></i> Stopped".html_safe
    when 'terminated'
      "<i class='fa fa-eject text-danger'></i> Terminated".html_safe
    else
      state
    end    
  end

  def usage_data_with_total(data, total)
    Hash[data.map{|k,v| [k.name,v]}].merge(total: total.round(2))
  end

  def usage_data_as_json(data, total)
    usage_data_with_total(data, total).to_json
  end

  def usage_data_as_xml(data, total)
    usage_data_with_total(data, total).to_xml(root: 'usage')
  end

  def usage_data_as_csv(data)
    CSV.generate do |csv|
      csv << ["Project", "Type", "Sub-Type", "Name", "Amount", "Unit", "Cost (£)"]
      data.each do |tenant, usage|
        usage[:instance_usage].each do |instance|
          csv << [tenant.name, "Instance", instance[:flavor][:name], instance[:name], instance[:billable_hours], 'hours', instance[:cost].round(2)]
        end
        usage[:volume_usage].each do |volume|
          csv << [tenant.name, "Volume", nil, volume[:name], volume[:terabyte_hours], 'TB/h', volume[:cost].round(2)]
        end
        usage[:image_usage].each do |image|
          csv << [tenant.name, "Image", nil, image[:name], image[:terabyte_hours], 'TB/h', image[:cost].round(2)]
        end
        csv << [tenant.name, "Object Storage", nil, nil, usage[:object_storage_usage].round(2), 'TB/h', (usage[:object_storage_usage] * RateCard.object_storage).round(2).nearest_penny]
        usage[:ip_quota_usage].each do |ip_quota|
          change = "From #{ip_quota.previous || '0'} IPs to #{ip_quota.quota} IPs"
          csv << [tenant.name, "Quota Change", nil, ip_quota.recorded_at, change, 'floating IPs', nil]
        end
        csv << [tenant.name, "IP quota", nil, nil, tenant.quota_set['network']['floatingip'], 'floating IPs', usage[:ip_quota_total]]
      end
    end
  end
end
