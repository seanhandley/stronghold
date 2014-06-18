module RolesHelper
  def list_of_roles(user)
    user.roles.map(&:name).join(', ')
  end

  def roles_for_select(organization)
    options_for_select(organization.roles.collect{|r| [r.name, r.id]})
  end
end