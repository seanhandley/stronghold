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

  def cached_servers
    Rails.cache.fetch("all_servers_for_freeze", expires_in: 2.minutes) do
      OpenStackConnection.compute.list_servers_detail(all_tenants: true).body['servers']
    end
  end

  def toggle_instances!(state)
    fog = OpenStackConnection.compute
    instances = tenants.collect do |tenant|
      cached_servers.select{|server| server['tenant_id'] == tenant.uuid}.map{|server| [server['id'], server['name'], tenant.name]}
    end.flatten
    if state
      instances.each do |instance_id, name, tenant|
        begin
          fog.unpause_server(instance_id)
          print '.'
        rescue StandardError => e
          "Couldn't unpause #{name} in project #{tenant}: #{e.message}"
        end
      end
    else
      instances.each do |instance_id, name, tenant|
        begin
          fog.pause_server(instance_id)
          print '.'
        rescue StandardError => e
          "Couldn't pause #{name} in project #{tenant}: #{e.message}"
        end
      end
    end
  end
end