class CustomerGenerator
  include ActiveModel::Validations

  attr_reader :organization_name, :email,        :products, :extra_projects,
              :salesforce_id,     :organization, :invite

  def initialize(params={})
    @organization_name = params[:organization_name]
    @email             = params[:email]
    @extra_projects     = params[:extra_projects]
    @salesforce_id     = params[:salesforce_id]
    if params[:organization] && params[:organization][:product_ids]
      @products = params[:organization][:product_ids].select(&:present?)
    else
      @products = []
    end
  end

  def generate!
    if @organization_name.blank?
      errors.add :base, "Must provide an organization name"
    elsif @email.blank? || !(@email =~ /.+@.+\..+/)
      errors.add :base, "Must provide a valid email address"
    elsif User.find_by_email(@email).present?
      errors.add :base, "Email already exists in the system"
    elsif @products.none?
      errors.add :base, "Select at least one product"
    elsif @products.any? {|p| !Product.all.map(&:id).include?(p.to_i)}
      errors.add :base, "Products invalid"
    else
      error = nil
      ApplicationRecord.transaction do
        begin
          create_customer
        rescue StandardError => e
          error = e
          raise ActiveRecord::Rollback
        end
      end

      raise error if error
      return true
    end
    false
  end

  private

  def create_customer
    @organization = Organization.create! name: @organization_name, self_service: false, salesforce_id: @salesforce_id, projects_limit: @extra_projects.split(',').count + 1
    @products.each do |product_id|
      @organization.products << Product.find(product_id)
    end
    @organization.save!
    @organization.transition_to!(:active)
    @organization.set_quotas!
    @extra_projects.split(',').map(&:strip).map(&:downcase).uniq.each do |project|
      @organization.projects.create(name: project)
    end
    if @organization.colo_only?
      @organization.projects.each do |project|
        project.update_attributes(quota_set: StartingQuota['zero'])
      end
    end
    @invite = Invite.create! email: @email, power_invite: true, organization: @organization, project_ids: [@organization.primary_project.id]
    Notifications.notify(:internal_signup, "New customer account created: #{@email} invited to organization #{@organization_name}")
  end
end
