module RolesHelper
  def list_of_roles(user)
    user.roles.map(&:name).join(', ')
  end

  def roles_for_select(organization)
    options_for_select(organization.roles.collect{|r| [r.name, r.id]})
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
      "#{content_tag(:span, "UNDELIVERED", class: "label label-danger")} (Mail server responded: #{status.downcase})"
    end
  end
end