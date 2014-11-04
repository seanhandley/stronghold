class CustomerGenerator
  include ActiveModel::Validations

  attr_reader :organization_name, :email, :colo_only, :extra_tenants

  def initialize(params={})
    @organization_name = params[:organization_name]
    @email             = params[:email]
    @colo_only         = params[:colo_only]
    @extra_tenants     = params[:extra_tenants]
  end

  def generate!
    if @organization_name.blank?
      errors.add :base, "Must provide an organization name"
    elsif @email.blank? || !(@email =~ /.+@.+\..+/)
      errors.add :base, "Must provide a valid email address"
    elsif User.find_by_email(@email).present?
      errors.add :base, "Email already exists in the system"
    else
      @organization = Organization.create! name: @organization_name
      @extra_tenants.split(',').map(&:strip).map(&:downcase).uniq.each do |tenant|
        uuid = @organization.tenants.create(name: tenant).uuid
        OpenStack::Tenant.find(uuid).zero_quotas if @colo_only
      end
      @invite = Invite.create! email: @email, power_invite: true, organization: @organization
      Mailer.signup(@invite.id).deliver
      return true
    end 
    false
  end
end