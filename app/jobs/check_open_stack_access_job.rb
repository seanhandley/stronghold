class CheckOpenStackAccessJob < ApplicationJob
  queue_as :default

  def perform(organization_user)
    if OrganizationUser::Ability.new(organization_user).can?(:read, :cloud)
      fog.update_user(organization_user.user.uuid, enabled: true)
    else
      fog.update_user(organization_user.user.uuid, enabled: false)
    end
  end

  def fog
    OpenStackConnection.identity
  end
end