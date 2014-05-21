class User::Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :new, :create, :edit, :update, :destroy, :read, :to => :modify

    can :read, Instance if user.has_permission?('instances.read')
    can :read, Role if user.has_permission?('roles.read')
    can :modify, Role if user.has_permission?('roles.modify')

    ## Power User can do everything
    can :modify, :all if user.power_user?

  end
end
