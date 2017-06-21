class OrganizationUser::Ability
  include CanCan::Ability

  def initialize(organization_user)
    return unless organization_user
    alias_action :new, :create, :edit, :update, :destroy, :read, :index, :to => :modify

    # Instances
    can :read, OpenStack::Instance   if organization_user.has_permission?('instances.read')
    can :modify, OpenStack::Instance if organization_user.has_permission?('instances.modify')

    # Roles
    if organization_user.has_permission?('roles.read')
      can :read, Role
      can :read, User
      can :read, OrganizationUserRole
    end

    if organization_user.has_permission?('roles.modify')
        can :modify, Role                 
        can :modify, User
        can :modify, OrganizationUserRole
        can :modify, Invite
    end

    # Tickets
    ticket_permissions          = ['tickets.modify', 'access_requests.raise_for_self', 'access_requests.raise_for_others']
    organization_user_has_ticket_permission  = -> (organization_user) { ticket_permissions.any?{|p| organization_user.has_permission?(p)} }

    can :modify, Ticket             if organization_user_has_ticket_permission.call(organization_user)
    can :modify, TicketComment      if organization_user_has_ticket_permission.call(organization_user)

    # Access Requests
    can :raise_for_self, Ticket     if organization_user.has_permission?('access_requests.raise_for_self')
    can :raise_for_others, Ticket   if organization_user.has_permission?('access_requests.raise_for_others')

    # Cloud
    can :read, :usage   if organization_user.has_permission?('usage.read')
    can :read, :cloud   if organization_user.has_permission?('cloud.read')
    can :read, :storage if organization_user.has_permission?('storage.read')
    can :read, :api     if organization_user.has_permission?('api.read')

    ## Power User can do everything
    can :modify, :all if organization_user.power_user?
    ## Can't do anything if account is frozen
    cannot :modify, :all if organization_user.organization.frozen?
  end
end
