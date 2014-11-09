class User::Ability
  include CanCan::Ability

  def initialize(user)
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
    can :modify, Ticket if user.has_permission?('tickets.modify')

    ## Power User can do everything
    can :modify, :all if user.power_user?

  end
end
