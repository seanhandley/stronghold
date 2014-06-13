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
    if !invite.is_valid?
      errors.add :base, 'Signup token is not valid'
    elsif password != confirm_password
      errors.add :base,  'Passwords do not match'
    elsif password.length < 8
      errors.add :base,  'Password is too short'
    elsif !invite.organization && organization_name.blank?
      errors.add :base, 'Organization name is blank'
    else
      unless invite.organization
        @organization = Organization.create(name: organization_name)
        @owners = @organization.roles.create name: 'Owners', power_user: true
      end
      @user = @organization.users.create email: invite.email, password: password,
                                         roles: (invite.roles << @owners)
      return true
    end 
    false
  end
end