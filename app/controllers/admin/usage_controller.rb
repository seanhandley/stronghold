class Admin::UsageController < AdminBaseController

  before_filter :get_organizations

  def index
    reset_dates
  end

  def create
    begin
      @from_date, @to_date = parse_dates create_params
      @total_hours = ((@to_date - @from_date) / 1.hour).round
      if (@organization = Organization.find(create_params[:organization]))
        @instance_results = usage('Billing::Instances', @organization, @from_date, @to_date)
        @volume_results = usage('Billing::Volumes', @organization, @from_date, @to_date)
        @image_results = usage('Billing::Images', @organization, @from_date, @to_date)
        @floating_ip_results = usage('Billing::FloatingIps', @organization, @from_date, @to_date)
        @external_gateway_results = usage('Billing::ExternalGateways', @organization, @from_date, @to_date)
      end
    rescue ArgumentError => e
      flash.now[:alert] = e.message
      reset_dates
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

  def parse_dates(params)
    from, to = [:from, :to].collect do |key|
      begin
        DateTime.civil(*params[key].sort.map(&:last).map(&:to_i))
      rescue ArgumentError => e
        raise ArgumentError, "The #{key.to_s} date is not a valid date"
      end
    end.collect{|d| Time.zone.parse(d.to_s)}

    if from < Billing::Sync.first.completed_at
      raise ArgumentError, "The earliest date we have usage for is #{Billing::Sync.first.completed_at}. Please ensure the start date is greater."
    end
    if to > Time.zone.now
      raise ArgumentError, "The end date cannot be in the future"
    end
    if to <= from
      raise ArgumentError, "The start date must be later than the end date"
    end

    return [from, to]
  end

  def reset_dates
    @from_date = Time.zone.now.last_month.beginning_of_month
    @from_date = Billing::Sync.first.completed_at if @from_date < Billing::Sync.first.completed_at
    @to_date = Time.zone.now.beginning_of_month
    @to_date = Time.zone.now if @to_date < @from_date
  end

end