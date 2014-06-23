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
      errors.add :base, 'Signup token is not valid'
    elsif password != confirm_password
      errors.add :base,  'Passwords do not match'
    elsif password.length < 8
      errors.add :base,  'Password is too short'
    elsif invite.power_invite? && organization_name.blank?
      errors.add :base, 'Organization name is blank'
    else
      if invite.power_invite?
        @organization = Organization.create(name: organization_name)
        @owners = @organization.roles.create name: 'Owners', power_user: true
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