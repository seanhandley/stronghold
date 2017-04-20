module RolesHelper
  def list_of_roles(user)
    user.roles.where(organization: current_organization).map(&:name).join(', ')
  end

  def list_of_projects(user)
    user.projects.where(organization: current_organization).map(&:name).uniq.join(', ')
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

  def invite_status_label(status)
    status = "pending" unless status.present?
    original_status = status.dup
    envelope = content_tag(:i, '', class: 'fa fa-envelope')
    status = "#{envelope} #{original_status.upcase}".html_safe
    case original_status.downcase
    when 'delivered'
      content_tag(:span, status, class: "label label-success")
    when 'pending'
      content_tag(:span, status, class: "label label-default")
    else
      "#{content_tag(:span, envelope + ' UNDELIVERED', class: "label label-danger")} <p class='text-danger'><em>(Mail server responded: #{original_status.downcase})</em></p>".html_safe
    end
  end
end