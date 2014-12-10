class User::Ability
  include CanCan::Ability

  def initialize(user)
    return unless user
    alias_action :new, :create, :edit, :update, :destroy, :read, :index, :to => :modify

    # Instances
    can :read, OpenStack::Instance if user.has_permission?('instances.read')
    can :modify, OpenStack::Instance if user.has_permission?('instances.modify')

    # Roles
    can :read, Role if user.has_permission?('roles.read')
    can :read, User if user.has_permission?('roles.read')
    can :modify, Role if user.has_permission?('roles.modify')
    can :modify, User if user.has_permission?('roles.modify')
    can :modify, RoleUser if user.has_permission?('roles.modify')
    can :modify, Invite if user.has_permission?('roles.modify')

    # Tickets
    # can :read, Ticket if user.has_permission?('tickets.read')
    can :modify, Ticket if user.has_permission?('tickets.modify') || user.has_permission?('access_requests.modify')

    ## Power User can do everything
    can :modify, :all if user.power_user?

    # Rails Admin
    if user.staff?
      can :access, :rails_admin
      can :dashboard
    end

  end
end
