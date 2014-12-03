class Admin::UsageController < AdminBaseController

  before_filter :get_organizations

  def index
    @from_date = Time.zone.now.last_month.beginning_of_month
    @to_date = Time.zone.now.beginning_of_month
  end

  def create
    @from_date, @to_date = [:from, :to].collect{|key| DateTime.civil(*create_params[key].sort.map(&:last).map(&:to_i))}.collect{|d| Time.zone.parse(d.to_s)}
    if (@organization = Organization.find(create_params[:organization]))
      @instance_results = usage('Billing::Instances', @organization, @from_date, @to_date)
      @volume_results = usage('Billing::Volumes', @organization, @from_date, @to_date)
      @floating_ip_results = usage('Billing::FloatingIps', @organization, @from_date, @to_date)
    end
    render :index
  end

  private

  def create_params
    params.permit(:organization, :from =>datetime_array, :to => datetime_array)
  end

  def get_organizations
    @organizations ||= Organization.all.collect{|o| [o.name, o.id]}
  end

  def datetime_array
    (1..5).map{|i| "(#{i}i)"}
  end

  def usage(type, organization, from, to)
    organization.tenants.inject({}) do |acc, tenant|
      acc[tenant.name] = type.constantize.usage(tenant.uuid, from, to)
      acc
    end
  end

end