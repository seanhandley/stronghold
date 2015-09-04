class RegistrationGenerator
  include ActiveModel::Validations

  attr_reader :invite, :password,
              :organization, :user

  def initialize(invite, params)
    @invite            = invite
    @password          = params[:password]
  end

  def generate!
    if !invite.can_register?
      errors.add :base, I18n.t(:signup_token_not_valid)
    elsif password.length < 8
      errors.add :base,  I18n.t(:password_too_short)
    else
      error = nil
      ActiveRecord::Base.transaction do
        begin
          create_registration
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

  def create_registration
    @organization = invite.organization
    if invite.power_invite?
      @owners = @organization.roles.create name: I18n.t(:owners), power_user: true
    end

    roles = (invite.roles + [@owners]).flatten.compact
    @user = @organization.users.create email: invite.email.downcase, password: password,
                                       roles: roles
    @user.save!
    OpenStack::User.update_enabled(@user.uuid, false) unless @organization.has_payment_method?
    if invite.power_invite?
      member_uuid = OpenStack::Role.all.select{|r| r.name == '_member_'}.first.id
      @organization.tenants.select{|t| t.id != @organization.primary_tenant.id}.each do |tenant|
        Fog::Identity.new(OPENSTACK_ARGS).create_user_role(tenant.uuid, @user.uuid, member_uuid)
      end
    end
    Notifications.notify(:new_user, "#{@user.name} added to organization #{@organization.name}.")
    # Add heat and storage roles
    unless Rails.env.test? || Rails.env.acceptance? || Rails.env.development?
      heat_roles = Fog::Identity.new(OPENSTACK_ARGS).list_roles.body['roles'].select{|r| r['name'].include? "heat_stack_owner"}.collect{|r| r['id']}
      heat_roles.each do |role|
        @organization.tenants.each do |tenant|
          Fog::Identity.new(OPENSTACK_ARGS).create_user_role(tenant.uuid, @user.uuid, role)
        end
      end

      storage_roles = Fog::Identity.new(OPENSTACK_ARGS).list_roles.body['roles'].select{|r| r['name'].include? "object-store"}.collect{|r| r['id']}
      storage_roles.each do |role|
        @organization.tenants.each do |tenant|
          Fog::Identity.new(OPENSTACK_ARGS).create_user_role(tenant.uuid, @user.uuid, role)
        end
      end
      
    end
    invite.complete!
  end
end