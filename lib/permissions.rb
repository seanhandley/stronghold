class Permissions
  class << self
    def user
      {
        # Instances
        # 'instances.read' => { :description => I18n.t(:can_instances_read), :group => I18n.t(:instances) },
        # 'instances.modify' => { :description => I18n.t(:can_instances_modify), :group => I18n.t(:instances) },

        # Roles
        'roles.read' => { :description => I18n.t(:can_roles_read), :group => I18n.t(:roles) },
        'roles.modify' => { :description => I18n.t(:can_roles_modify), :group => I18n.t(:roles) },
        'roles.invite' => { :description => I18n.t(:can_roles_invite), :group => I18n.t(:roles) }

      }
    end
  end
end