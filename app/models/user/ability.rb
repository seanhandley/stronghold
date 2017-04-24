class User::Ability
  include CanCan::Ability

  def initialize(user)
    return unless user
    alias_action :new, :create, :edit, :update, :destroy, :read, :index, :to => :modify

    # Instances
    can :read, OpenStack::Instance   if user.has_permission?('instances.read')
    can :modify, OpenStack::Instance if user.has_permission?('instances.modify')

    # Roles
    can :read, Role       if user.has_permission?('roles.read')
    can :read, User       if user.has_permission?('roles.read')
    can :modify, Role     if user.has_permission?('roles.modify')
    can :modify, User     if user.has_permission?('roles.modify')
    can :modify, RoleUser if user.has_permission?('roles.modify')
    can :modify, Invite   if user.has_permission?('roles.modify')

    # Tickets
    ticket_permissions          = ['tickets.modify', 'access_requests.raise_for_self', 'access_requests.raise_for_others']
    user_has_ticket_permission  = -> (user) { ticket_permissions.any?{|p| user.has_permission?(p)} }

    can :modify, Ticket             if user_has_ticket_permission.call(user)
    can :modify, TicketComment      if user_has_ticket_permission.call(user)

    # Access Requests
    can :raise_for_self, Ticket     if user.has_permission?('access_requests.raise_for_self')
    can :raise_for_others, Ticket   if user.has_permission?('access_requests.raise_for_others')

    # Cloud
    can :read, :usage   if user.has_permission?('usage.read')
    can :read, :cloud   if user.has_permission?('cloud.read')
    can :read, :storage if user.has_permission?('storage.read')
    can :read, :api     if user.power_user?

    ## Power User can do everything
    can :modify, :all if user.power_user?
  end
end
