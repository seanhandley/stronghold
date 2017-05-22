module RolesHelper
  def list_of_roles(user)
    user.roles.where(organization: user.current_organization).map(&:name).join(', ')
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

  def users_for_select(role)
    options_for_select([role.organization.users - role.users].flatten.collect{|u| [u.name, u.id]})
  end

  def active_tab?(name)
    if params[:tab] && params[:tab].present?
      params[:tab] == name ? 'active' : ''
    else
      name == 'users' ? 'active' : ''
    end
  end
end
