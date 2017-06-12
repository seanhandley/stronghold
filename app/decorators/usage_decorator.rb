class UsageDecorator < ApplicationDecorator
  attr_reader :year, :month

  def initialize(organization, year=Time.now.year, month=Time.now.month)
    @year, @month = year, month
    super(organization)
  end

  def from_date
    Time.parse("#{year}-#{month}-01").beginning_of_month
  end

  def to_date
    [Time.now, from_date.end_of_month].min
  end
  
  def usage_data(force: false)
    @usage_data ||= UsageStorage.fetch(year: year, month: month, organization_id: model.id, force: force) do
      model.projects.with_deleted.where("created_at < ?", to_date).select{|t| t.deleted_at.nil? || t.deleted_at > from_date}.map do |project|
        {
          id: project.uuid,
          name: project.name,
          usage: {
            images:         Billing::Images.usage(project.uuid, from_date, to_date),
            instances:      Billing::Instances.usage(project.uuid, from_date, to_date),
            ips:            Billing::IpQuotas.usage(project, from_date, to_date),
            load_balancers: Billing::LoadBalancers.usage(project.uuid, from_date, to_date),
            object_storage: Billing::StorageObjects.usage(project.uuid, from_date, to_date),
            volumes:        Billing::Volumes.usage(project.uuid, from_date, to_date),
            vpns:           Billing::VpnConnections.usage(project.uuid, from_date, to_date)
          }
        }
      end
    end
    {
      last_updated_at: Billing::Usage.find_by(organization_id: model.id, year: year, month: month)&.updated_at,
      projects:        @usage_data
    }
  end

  def instance_total(project_id, flavor_id=nil)
    usage_data[:projects].each do |results|
      if(project_id == results[:id])
        results = results[:usage][:instances]
        if flavor_id
          results = results.select{|i| i[:current_flavor][:id] == flavor_id}
        end
        return results.sum{|i| i[:usage].sum{|u| u[:cost][:value]}}.nearest_penny
      end
    end
    return 0
  end

  def volume_total(project_id)
    usage_data[:projects].each do |results|
      if(project_id == results[:id])
        return results[:usage][:volumes].sum{|i| i[:usage].sum{|u| u[:cost][:value]}}.nearest_penny
      end
    end
    return 0
  end

  def image_total(project_id)
    usage_data[:projects].each do |results|
      if(project_id == results[:id])
        return results[:usage][:images].sum{|i| i[:usage].sum{|u| u[:cost][:value]}}.nearest_penny
      end
    end
    return 0
  end

  def load_balancer_total(project_id)
    usage_data[:projects].each do |results|
      if(project_id == results[:id])
        return results[:usage][:load_balancers]&.sum{|i| i[:usage].sum{|u| u[:cost][:value]}}.nearest_penny || 0
      end
    end
    return 0
  end

  def vpn_connection_total(project_id)
    usage_data[:projects].each do |results|
      if(project_id == results[:id])
        return results[:usage][:vpns]&.sum{|i| i[:usage].sum{|u| u[:cost][:value]}}.nearest_penny || 0
      end
    end
    return 0
  end

  def ip_quota_total(project_id)
    usage_data[:projects].each do |results|
      if(project_id == results[:id])
        return results[:usage][:ips][:usage].sum{|u| u[:cost][:value]}.nearest_penny
      end
    end
    return 0
  end

  def object_storage_total(project_id)
    usage_data[:projects].each do |results|
      if(project_id == results[:id])
        return (results[:usage][:object_storage][:usage].sum{|u| u[:cost][:value]}).nearest_penny
      end
    end
    return 0
  end

  def total(project_id)
    [
      instance_total(project_id), volume_total(project_id),
      image_total(project_id),
      ip_quota_total(project_id), 
      object_storage_total(project_id),
      load_balancer_total(project_id),
      vpn_connection_total(project_id)
    ].sum
  end

  def sub_total
    model.projects.with_deleted.collect{|t| total(t.uuid)}.sum
  end

  def discounts?
    !!active_discount
  end

  def discount_percent
    active_discount ? active_discount.voucher.discount_percent : 0.0
  end

  def active_discount
    model.active_vouchers(from_date, to_date).first
  end

  def tax_percent
    20
  end

  def grand_total
    return sub_total unless discounts?
    v = active_discount
    voucher_start = v.created_at
    voucher_end = v.expires_at

    totals = []
    
    # Calculate the part of the month that needs a discount
    from = (voucher_start < from_date) ? from_date : voucher_start
    to   = (voucher_end > to_date) ? to_date : voucher_end

    ud = UsageDecorator.new(model)

    ud.usage_data
    discounted_total = ud.sub_total  * (1 - (discount_percent / 100.0))
    totals << discounted_total

    # Calculate the remainder at the start
    if from > from_date
      ud.usage_data
      totals << ud.sub_total
    end

    # Calculate remainder at the end
    if to < to_date
      ud.usage_data
      totals << ud.sub_total
    end

    totals.sum
  end

  def grand_total_plus_tax
    grand_total + (grand_total * 0.2)
  end

  private

  def timestamp_format
    "%Y%m%d%H"
  end
end