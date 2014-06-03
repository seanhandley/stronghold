module RolesHelper
  def list_of_roles(user)
    user.roles.map(&:name).join(', ')
  end
end