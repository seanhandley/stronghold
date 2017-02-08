class Permissions
  class << self
    def user
      perms = {
        # Roles
        'roles.read'   => { :description => I18n.t(:can_roles_read),   :group => I18n.t(:roles) },
        'roles.modify' => { :description => I18n.t(:can_roles_modify), :group => I18n.t(:roles) },

        # Support Tickets
        'tickets.modify' => { :description => I18n.t(:can_tickets_modify), :group => I18n.t(:tickets) }
      }
      if Authorization.current_organization&.colo?
        perms.merge!({'access_requests.raise_for_others' => { :description => I18n.t(:can_raise_access_request_for_others), :group => I18n.t(:access_requests) }})
        perms.merge!({'access_requests.raise_for_self'   => { :description => I18n.t(:can_raise_access_request_for_self),   :group => I18n.t(:access_requests) }})
      end
      if Authorization.current_organization&.cloud?
        perms.merge!('usage.read'   => { :description => I18n.t(:can_usage_read),     :group => I18n.t(:cloud) })
        perms.merge!('cloud.read'   => { :description => I18n.t(:can_cloud_access),   :group => I18n.t(:cloud) })
        perms.merge!('storage.read' => { :description => I18n.t(:can_storage_access), :group => I18n.t(:cloud) })
      end
      if Authorization.current_organization&.staff?
        perms.merge!('api.read'     => { :description => I18n.t(:can_api_access),     :group => I18n.t(:cloud) })
      end

      return perms
    end
  end
end
