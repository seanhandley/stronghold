module RolesHelper
  def list_of_roles(user)
    user.roles.collect do |role|
      content_tag(:a, role.name, :href => '#')
    end.join(', ').html_safe
  end
end