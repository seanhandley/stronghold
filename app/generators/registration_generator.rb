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
      ApplicationRecord.transaction do
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
    Authorization.current_organization = @organization
    if invite.power_invite?
      @owners = @organization.roles.create name: I18n.t(:owners), power_user: true
    end

    roles = (invite.roles + [@owners]).flatten.compact
    @user = @organization.users.create email: invite.email.downcase, password: password
    @user.save!
    @organization_user = OrganizationUser.find_by(organization: @organization, user: @user)
    @organization_user.update_attributes roles: roles
    unless Rails.env.test?
      invite.projects.each do |project|
        UserProjectRole.required_role_ids.each do |role_uuid|
          UserProjectRole.create(user_id: @user.id, project_id: project.id,
                                role_uuid: role_uuid)
        end
      end
    end
    
    Notifications.notify(:new_user, "#{@user.name} added to organization #{@organization.name}.")

    invite.complete!
  end
end