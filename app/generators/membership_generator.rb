class MembershipGenerator
  include ActiveModel::Validations

  attr_reader :invite,
              :organization, :user

  def initialize(invite)
    @invite = invite
  end

  def generate!
    if !invite.can_register?
      errors.add :base, I18n.t(:membership_token_not_valid)
    else
      error = nil
      ApplicationRecord.transaction do
        begin
          create_membership
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

  def create_membership
    @organization = invite.organization
    Authorization.current_organization = @organization
    if invite.power_invite?
      @owners = @organization.roles.create name: I18n.t(:owners), power_user: true
    end

    @user ||= User.find_by_email(invite.email.downcase)
    roles = (invite.roles + [@owners]).flatten.compact

    @organization_user = OrganizationUser.new organization_id: @organization.id, user_id: @user.id
    @organization_user.save!
    @organization_user.update_attributes roles: roles
    OpenStack::User.update_enabled(@user.uuid, false) unless @organization.has_payment_method?
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
