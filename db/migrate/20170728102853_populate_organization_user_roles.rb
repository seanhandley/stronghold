class PopulateOrganizationUserRoles < ActiveRecord::Migration[5.0]
  def change
    RoleUser.find_each do |role_user|
      organization_user = OrganizationUser.find_by(user: role_user.user, organization: role_user.role&.organization)
      OrganizationUserRole.create role: role_user.role, organization_user: organization_user
    end

    UserProjectRole.find_each do |user_project_role|
      organization_user = OrganizationUser.find_by(user: user_project_role.user, organization: user_project_role.project&.organization)
      next unless organization_user
      user_project_role.update_column :organization_user_id, organization_user.id
    end

    ApiCredential.find_each do |api_credential|
      organization_user = OrganizationUser.find_by(user_id: api_credential.user_id, organization_id: api_credential&.organization_id)
      next unless organization_user
      api_credential.update_column :organization_user_id, organization_user.id
    end
  end
end
