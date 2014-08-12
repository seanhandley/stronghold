class Registration
  include ActiveModel::Validations

  attr_reader :invite, :password, :confirm_password,
              :organization, :organization_name, :user

  def initialize(invite, params)
    @invite            = invite
    @password          = params[:password]
    @confirm_password  = params[:confirm_password]
    @organization_name = params[:organization_name]
  end

  def process!
    if !invite.can_register?
      errors.add :base, I18n.t(:signup_token_not_valid)
    elsif password != confirm_password
      errors.add :base,  I18n.t(:passwords_dont_match)
    elsif password.length < 8
      errors.add :base,  I18n.t(:password_too_short)
    elsif invite.power_invite? && organization_name.blank?
      errors.add :base, I18n.t(:organization_name_is_blank)
    else
      if invite.power_invite?
        @organization = Organization.create(name: organization_name)
        @owners = @organization.roles.create name: I18n.t(:owners), power_user: true
      else
        @organization = invite.organization
      end
      
      roles = (invite.roles + [@owners]).flatten.compact
      @user = @organization.users.create email: invite.email, password: password,
                                         roles: roles
      @invite.complete!
      return true
    end 
    false
  end
end