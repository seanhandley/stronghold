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

  def instance_flavor_name(instance)
    [instance[:current_flavor][:name], instance[:tags].select{|t| t == "windows"}.map{|t| " (#{t.capitalize})"}].join
  end

  def usage_data_as_csv(data)
    CSV.generate do |csv|
      csv << ["Project", "Type", "Sub-Type", "ID", "Name", "Amount", "Unit", "Cost (£)"]
      data[:projects].each do |project|
        project[:usage][:instances].each do |instance|
          instance[:usage].each do |usage|
            csv << [project[:name], "Instance", instance_flavor_name(instance) , usage[:meta][:flavor][:id], usage[:meta][:name], usage[:value], 'hours', usage[:cost][:value]]
          end
        end
        project[:usage][:volumes].each do |volume|
          volume[:usage].each do |usage|
            csv << [project[:name], "Volume", usage[:meta][:volume_type], volume[:id], volume[:name], usage[:value], 'TB/h', usage[:cost][:value]]
          end
        end
        project[:usage][:images].each do |image|
          image[:usage].each do |usage|
            csv << [project[:name], "Image", nil, image[:id], image[:name], usage[:value], 'TB/h', usage[:cost][:value]]
          end
        end
        project[:usage][:object_storage][:usage].each do |usage|
          csv << [project[:name], "Object Storage", nil, nil, nil, usage[:value].round(2), 'TB/h', usage[:cost][:value]]
        end
        project[:usage][:ips][:usage].each do |usage|
          csv << [project[:name], "IP quota", nil, nil, nil, usage[:value], 'floating IPs', usage[:cost][:value]]
        end
        project[:usage][:load_balancers].each do |load_balancer|
          load_balancer[:usage].each do |usage|
            csv << [project[:name], "Load Balancer", nil, load_balancer[:id], load_balancer[:name], usage[:value], "hours", usage[:cost][:value]]
          end
        end
        project[:usage][:vpns].each do |vpns|
          vpns[:usage].each do |usage|
            csv << [project[:name], "VPN Connection", nil, vpns[:id], vpns[:name], usage[:value], "hours", usage[:cost][:value]]
          end
        end
      end
    end
  end
end
