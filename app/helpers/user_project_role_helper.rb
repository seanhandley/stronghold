module UserProjectRoleHelper

  def users_with_openstack_permissions
    current_organization.organization_users.select{|ou| ou.has_permission?('cloud.read')}.map(&:user)
  end

  def user_project_roles_attributes
    users_in_this_org = users_with_openstack_permissions.collect(&:id)
    users_destined_for_this_project = project_params[:users].present? ? project_params[:users].keys.map(&:to_i).select{|u| User.find_by_id(u)}.compact : []
    users_not_destined_for_this_project = users_in_this_org - users_destined_for_this_project

    utrs_for_removal = users_not_destined_for_this_project.collect do |u|
      UserProjectRole.where(:project_id => @project.id, :user_id => u)
    end.flatten.compact

    attrs = []

    attrs << utrs_for_removal.map{|utr| {id: utr.id.to_s, _destroy: '1'}}

    utrs_for_adding = users_destined_for_this_project.collect do |u|
      UserProjectRole.required_role_ids.collect do |role_uuid|
        if UserProjectRole.where(user_id: u, project_id: @project.id, role_uuid: role_uuid).none?
          {user_id: u, project_id: @project.id, role_uuid: role_uuid}
        else
          nil
        end
      end
    end.flatten.compact

    attrs << utrs_for_adding

    {user_project_roles_attributes: attrs.flatten.compact}

  end
end