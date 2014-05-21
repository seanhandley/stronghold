class Permissions
  class << self
    def user
      {
        # Instances
        'instances.read' => { :description => 'Can view instances', :group => 'Instances' },
        'instances.modify' => { :description => 'Can manage instances', :group => 'Instances' },

        # Roles
        'roles.read' => { :description => 'Can view roles', :group => 'Roles' },
        'roles.modify' => { :description => 'Can manage roles', :group => 'Roles' }

      }
    end
  end
end