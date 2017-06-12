module UsageHelper
  include ActionView::Helpers::FormOptionsHelper

  def named_month_and_year(month, year)
    "#{Date::MONTHNAMES[month]} #{year}"
  end

  def usages_for_select(organization)
    organization.started_paying_at
    entries = billing_range(organization).select{|date| date.day == 1}.map do |date|
      {year: date.year, month: date.month}
    end

    coll = entries.collect do |entry|
      [named_month_and_year(entry[:month], entry[:year]), support_usage_path(entry)]
    end

    options_for_select(coll, selected: support_usage_path(month: params[:month], year: params[:year]))
  end

  def usages_for_admin_select(organization)
    organization.started_paying_at
    entries = billing_range(organization).select{|date| date.day == 1}.map do |date|
      {year: date.year, month: date.month}
    end

    coll = entries.collect do |entry|
      ["#{Date::MONTHNAMES[entry[:month]]} #{entry[:year]}", "#{entry[:year]},#{entry[:month]}"]
    end

    options_for_select(coll, selected: "#{params[:year]},#{params[:month]}")
  end

  def billing_range(organization)
    (organization.created_at.beginning_of_month.to_date..Date.today.end_of_month).to_a.reverse
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

  def flavors
    @flavors ||= Hash[Billing::InstanceFlavor.all.map{|f| [f.flavor_id, f.name]}]
  end

  def usage_data_as_csv(data)
    CSV.generate do |csv|
      csv << ["Project", "Type", "Sub-Type", "ID", "Name", "Amount", "Unit", "Cost (£)"]
      data.each do |project, usage|
        usage[:instances].each do |instance|
          instance[:billable_hours].each do |flavor_id, hours|
            csv << [project.name, "Instance", flavors[flavor_id] + (instance[:windows] ? " (Windows)" : ""), instance[:uuid], instance[:name], hours, 'hours', instance[:cost_by_flavor][flavor_id].nearest_penny]
          end
        end

        usage[:volumes].each do |volume|
          csv << [project.name, "Volume", volume[:volume_type_name], volume[:id], volume[:name], volume[:terabyte_hours], 'TB/h', volume[:cost]]
        end
        usage[:images].each do |image|
          csv << [project.name, "Image", nil, image[:id], image[:name], image[:terabyte_hours], 'TB/h', image[:cost]]
        end
        csv << [project.name, "Object Storage", nil, nil, nil, usage[:object_storage].round(2), 'TB/h', (usage[:object_storage] * RateCard.object_storage).nearest_penny]
        usage[:ip_quota_usage].each do |ip_quota|
          change = "From #{ip_quota.previous || '0'} IPs to #{ip_quota.quota} IPs"
          csv << [project.name, "Quota Change", nil, nil, ip_quota.recorded_at, change, 'floating IPs', nil]
        end
        csv << [project.name, "IP quota", nil, nil, nil, project.quota_set['network']['floatingip'], 'floating IPs', usage[:ip_quota_total]]
        usage[:load_balancers].each do |load_balancer|
          csv << [project.name, "Load Balancer", nil, load_balancer[:id], load_balancer[:name], load_balancer[:hours], "hours", load_balancer[:cost]]
        end
        usage[:vpns].each do |vpn_connection|
          csv << [project.name, "VPN Connection", nil, vpn_connection[:id], vpn_connection[:name], vpn_connection[:hours], "hours", vpn_connection[:cost]]
        end
      end
    end
  end
end
