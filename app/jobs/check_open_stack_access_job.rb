class CheckOpenStackAccessJob < ApplicationJob
  queue_as :default

  def perform(organization_user)
    unless OrganizationUser::Ability.new(organization_user).can?(:read, :cloud)
      organization_user.user_project_roles.destroy_all
    end
  end
end