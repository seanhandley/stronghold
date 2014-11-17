class RegistrationGenerator
  include ActiveModel::Validations

  attr_reader :invite, :password, :confirm_password,
              :organization, :user, :privacy,
              :first_name, :last_name

  def initialize(invite, params)
    @invite            = invite
    @password          = params[:password]
    @confirm_password  = params[:confirm_password]
    @privacy           = params[:privacy]
    @first_name        = params[:first_name]
    @last_name         = params[:last_name]
  end

  def generate!
    if @privacy.blank?
      errors.add :base, I18n.t(:must_agree_to_privacy)
    elsif !invite.can_register?
      errors.add :base, I18n.t(:signup_token_not_valid)
    elsif first_name.blank? || last_name.blank?
      errors.add :base, I18n.t(:must_provide_first_name_and_last_name)
    elsif password != confirm_password
      errors.add :base,  I18n.t(:passwords_dont_match)
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
    @user = @organization.users.create email: invite.email, password: password,
                                       roles: roles, first_name: first_name, last_name: last_name

    if invite.power_invite?
      member_uuid = OpenStack::Role.all.select{|r| r.name == '_member_'}.first.id
      @organization.tenants.select{|t| t.id != @organization.primary_tenant.id}.each do |tenant|
        UserTenantRole.create user: @user, tenant: tenant, role_uuid: member_uuid
      end
    end
    @invite.complete!
  end
end