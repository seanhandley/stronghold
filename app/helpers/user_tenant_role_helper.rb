module UserTenantRoleHelper
  def user_tenant_roles_attributes
    users_in_this_org = current_organization.users.collect(&:id)
    users_destined_for_this_tenant = tenant_params[:users].present? ? tenant_params[:users].keys.map(&:to_i).select{|u| User.find_by_id(u)}.compact : []
    users_not_destined_for_this_tenant = users_in_this_org - users_destined_for_this_tenant

    utrs_for_removal = users_not_destined_for_this_tenant.collect do |u|
      UserTenantRole.where(:tenant_id => @tenant.id, :user_id => u)
    end.flatten.compact

    attrs = []

    attrs << utrs_for_removal.map{|utr| {id: utr.id.to_s, _destroy: '1'}}

    utrs_for_adding = users_destined_for_this_tenant.collect do |u|
      UserTenantRole.required_role_ids.collect do |role_uuid|
        if UserTenantRole.where(user_id: u, tenant_id: @tenant.id, role_uuid: role_uuid).none?
          {user_id: u, tenant_id: @tenant.id, role_uuid: role_uuid}
        else
          nil
        end
      end
    end.flatten.compact

    attrs << utrs_for_adding

    {user_tenant_roles_attributes: attrs.flatten.compact}

  end
end