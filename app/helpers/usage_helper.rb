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

  def flavors
    @flavors ||= Hash[Billing::InstanceFlavor.all.map{|f| [f.flavor_id, f.name]}]
  end

  def usage_data_as_csv(data)
    CSV.generate do |csv|
      csv << ["Project", "Type", "Sub-Type", "ID", "Name", "Amount", "Unit", "Cost (£)"]
      data.each do |project, usage|
        usage[:instance_usage].each do |instance|
          instance[:billable_hours].each do |flavor_id, hours|
            csv << [project.name, "Instance", flavors[flavor_id], instance[:uuid], instance[:name], hours, 'hours', instance[:cost_by_flavor][flavor_id].nearest_penny]
          end
        end

        usage[:volume_usage].each do |volume|
          csv << [project.name, "Volume", volume[:volume_type_name], volume[:id], volume[:name], volume[:terabyte_hours], 'TB/h', volume[:cost]]
        end
        usage[:image_usage].each do |image|
          csv << [project.name, "Image", nil, image[:id], image[:name], image[:terabyte_hours], 'TB/h', image[:cost]]
        end
        csv << [project.name, "Object Storage", nil, nil, nil, usage[:object_storage_usage].round(2), 'TB/h', (usage[:object_storage_usage] * RateCard.object_storage).nearest_penny]
        usage[:ip_quota_usage].each do |ip_quota|
          change = "From #{ip_quota.previous || '0'} IPs to #{ip_quota.quota} IPs"
          csv << [project.name, "Quota Change", nil, nil, ip_quota.recorded_at, change, 'floating IPs', nil]
        end
        csv << [project.name, "IP quota", nil, nil, nil, project.quota_set['network']['floatingip'], 'floating IPs', usage[:ip_quota_total]]
        usage[:load_balancer_usage].each do |load_balancer|
          csv << [project.name, "Load Balancer", nil, load_balancer[:lb_id], load_balancer[:name], load_balancer[:hours], "hours", load_balancer[:cost]]
        end
        usage[:vpn_connection_usage].each do |vpn_connection|
          csv << [project.name, "VPN Connection", nil, vpn_connection[:vpn_connection_id], vpn_connection[:name], vpn_connection[:hours], "hours", vpn_connection[:cost]]
        end
      end
    end
  end
end
