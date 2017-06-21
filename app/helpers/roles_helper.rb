module RolesHelper
  def list_of_roles(organization_user)
    organization_user.roles.map(&:name).join(', ')
  end

  def list_of_projects(user)
    user.projects.where(organization: user.current_organization).map(&:name).uniq.join(', ')
  end

  def roles_for_select(organization)
    options_for_select(organization.roles.collect{|r| [r.name, r.id]})
  end

  def projects_for_select(organization)
    options_for_select(organization.projects.collect{|r| [r.name, r.id]})
  end

  def organization_users_for_select(role)
    options_for_select(
      [role.organization.organization_users - role.organization_users].flatten.map do |u|
        [u.user.name_with_email, u.id]
      end
    )
  end

  def active_tab?(name)
    if params[:tab] && params[:tab].present?
      params[:tab] == name ? 'active' : ''
    else
      name == 'users' ? 'active' : ''
    end
  end
end
