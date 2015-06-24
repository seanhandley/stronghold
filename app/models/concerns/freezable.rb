module Freezable

  # Lock out of OpenStack, but leave instances and storage accessible
  def soft_freeze!
    disable_users!
    disable_tenants!
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
      send("#{coll}s").each do |e|
        Fog::Identity.new(OPENSTACK_ARGS).send("update_#{coll}".to_sym, e.uuid, enabled: state)
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
        rescue Net::HTTPError => e
          Honeybadger.notify(e)
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

  def toggle_instances!(state)
    fog = Fog::Compute.new(OPENSTACK_ARGS)
    instances = tenants.collect do |tenant|
      fog.list_servers_detail(all_tenants: true).body['servers'].select{|s| s['tenant_id'] == tenant.uuid}.map{|s| s['id']}
    end.flatten
    if state
      instances.each {|instance| fog.unpause_server(instance)}
    else
      instances.each {|instance| fog.pause_server(instance)}
    end
  end
end