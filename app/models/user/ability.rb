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
    can :modify, Ticket             if user.has_permission?('tickets.modify') || user.has_permission?('access_requests.modify')
    can :modify, TicketComment      if user.has_permission?('tickets.modify') || user.has_permission?('access_requests.modify')
    can :raise_for_self, Ticket     if user.has_permission?('tickets.raise_for_self') || user.has_permission?('access_requests.raise_for_self')
    can :raise_for_others, Ticket   if user.has_permission?('tickets.raise_for_others') || user.has_permission?('access_requests.raise_for_others')

    # Cloud
    can :read, :usage if user.has_permission?('usage.read')
    can :read, :cloud if user.has_permission?('cloud.read')
    can :read, :storage if user.has_permission?('storage.read')

    ## Power User can do everything
    can :modify, :all if user.power_user?

    # Rails Admin
    if user.staff?
      can :access, :rails_admin
      can :dashboard
    end

  end
end
