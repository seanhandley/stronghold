class Permissions
  class << self
    def user
      perms = {
        # Instances
        # 'instances.read' => { :description => I18n.t(:can_instances_read), :group => I18n.t(:instances) },
        # 'instances.modify' => { :description => I18n.t(:can_instances_modify), :group => I18n.t(:instances) },

        # Roles
        'roles.read' => { :description => I18n.t(:can_roles_read), :group => I18n.t(:roles) },
        'roles.modify' => { :description => I18n.t(:can_roles_modify), :group => I18n.t(:roles) },

        # Support Tickets
        #'tickets.read' => { :description => I18n.t(:can_tickets_read), :group => I18n.t(:tickets) },
        'tickets.modify' => { :description => I18n.t(:can_tickets_modify), :group => I18n.t(:tickets) }

      }
      if Authorization.current_user && Authorization.current_user.organization.colo?
        perms.merge!({'access_requests.modify' => { :description => I18n.t(:can_access_requests_modify), :group => I18n.t(:access_requests) }})
      end

      if Authorization.current_user && Authorization.current_user.organization.cloud?
        perms.merge!('usage.read'   => { :description => I18n.t(:can_usage_read), :group => I18n.t(:cloud) })
        perms.merge!('cloud.read' => { :description => I18n.t(:can_cloud_access), :group => I18n.t(:cloud) })
      end

      return perms
    end
  end
end