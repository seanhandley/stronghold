class StuckIp
  attr_accessor :public_ip, :tenant_id, :instance_id

  def initialize(params)
    @public_ip   = params[:public_ip]
    @tenant_id   = params[:tenant_id]
    @instance_id = params[:instance_id]
  end

  def organization
    @organization ||= project&.organization
  end

  def project
    @project ||= Project.find_by_uuid tenant_id
  end

  def instance
    @instance ||= Billing::Instance.find_by_instance_id instance_id
  end
end
