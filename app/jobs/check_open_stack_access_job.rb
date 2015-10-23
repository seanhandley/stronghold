class CheckOpenStackAccessJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    if User::Ability.new(user).can?(:read, :cloud)
      fog.update_user(user.uuid, enabled: true)
      set_roles_and_tenants(user)
    else
      fog.update_user(user.uuid, enabled: false)
    end
  end

  def fog
    OpenStackConnection.identity
  end

  def set_roles_and_tenants(user)
    member_uuid = OpenStack::Role.all.select{|r| r.name == '_member_'}.first.id
    storage_roles = fog.list_roles.body['roles'].select{|r| r['name'].include? "object-store"}.collect{|r| r['id']}
    heat_roles = fog.list_roles.body['roles'].select{|r| r['name'].include? "heat_stack_owner"}.collect{|r| r['id']}

    roles = [member_uuid, storage_roles, heat_roles].flatten

    unless Rails.env.test? || Rails.env.acceptance? || Rails.env.development?
      roles.each do |role|
        user.organization.tenants.each do |tenant|
          begin
            fog.create_user_role(tenant.uuid, user.uuid, role)
          rescue Excon::Errors::Conflict
            # Already a member - swallow error
          end
        end
      end
    end
  end
end