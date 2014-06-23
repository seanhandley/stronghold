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

  def valid?
    if !invite.can_register?
      errors.add :base, 'Signup token is not valid'
    elsif password != confirm_password
      errors.add :base,  'Passwords do not match'
    elsif password.length < 8
      errors.add :base,  'Password is too short'
    elsif !invite.organization && organization_name.blank?
      errors.add :base, 'Organization name is blank'
    else
      if invite.organization
        @organization = invite.organization
      else
        @organization = Organization.create(name: organization_name)
        @owners = @organization.roles.create name: 'Owners', power_user: true
      end
      
      roles = (invite.roles + [@owners]).flatten.compact
      @user = @organization.users.create email: invite.email, password: password,
                                         roles: roles
      return true
    end 
    false
  end
end