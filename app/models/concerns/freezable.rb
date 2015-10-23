module Freezable

  # Lock out of OpenStack, but leave instances and storage accessible
  def soft_freeze!
    disable_users!
    disable_tenants!
    update_attributes(in_review: true)
    true
  end

  # Lock out of OpenStack and Ceph, and pause all instances
  def hard_freeze!
    soft_freeze!
    disable_storage!
    pause_instances!
    true
  end

  def unfreeze!
    enable_users!
    enable_tenants!
    enable_storage!
    unpause_instances!
    update_attributes(in_review: false)
    true
  end

  private

  def enable_users!
    toggle_openstack!('user', true)
  end

  def disable_users!
    toggle_openstack!('user', false)
  end

  def enable_tenants!
    toggle_openstack!('tenant', true)
  end

  def disable_tenants!
    toggle_openstack!('tenant', false)
  end

  def toggle_openstack!(coll, state)
    unless Rails.env.test?
      send("#{coll}s").each do |entity|
        OpenStackConnection.identity.send("update_#{coll}".to_sym, entity.uuid, enabled: state)
      end
    end
  end

  def enable_storage!
    toggle_ceph!(true)
  end

  def disable_storage!
    toggle_ceph!(false)
  end

  def toggle_ceph!(state)
    unless Rails.env.test?
      tenants.each do |tenant|
        begin
          Ceph::User.update('uid' => tenant.uuid, 'suspended' => !state)
        rescue Net::HTTPError => error
          Honeybadger.notify(error)
        end
      end
    end
  end

  def unpause_instances!
    toggle_instances!(true)
  end

  def pause_instances!
    toggle_instances!(false)
  end

  private

  def toggle_instances!(state)
    fog = OpenStackConnection.compute
    instances = tenants.collect do |tenant|
      fog.list_servers_detail(all_tenants: true).body['servers'].select{|server| server['tenant_id'] == tenant.uuid}.map{|server| server['id']}
    end.flatten
    if state
      instances.each do |instance|
        begin
          fog.unpause_server(instance)
        rescue Excon::Errors::Conflict
          # Already unpaused
        end
      end
    else
      instances.each do |instance|
        begin
          fog.pause_server(instance)
        rescue Excon::Errors::Conflict
          # Already paused
        end
      end
    end
  end
end