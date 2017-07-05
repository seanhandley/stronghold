# This Freezable module is responsible for freezing server.
module Freezable
  # Lock out of OpenStack, but leave instances and storage accessible
  def soft_freeze!
    disable_users_and_projects!
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
    enable_users_and_projects!
    enable_storage!
    unpause_instances!
    true
  end

  def disable_users_and_projects!
    disable_users!
    disable_projects!
  end

  def enable_users_and_projects!
    enable_users!
    enable_projects!
  end

  private

  def enable_users!
    toggle_openstack!('user', true)
  end

  def disable_users!
    toggle_openstack!('user', false)
  end

  def enable_projects!
    toggle_openstack!('project', true)
  end

  def disable_projects!
    toggle_openstack!('project', false)
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
      projects.each do |project|
        begin
          Ceph::User.update('uid' => project.uuid, 'suspended' => !state)
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

  # def toggle_server(action)
  #   instances.each do |instance_id, name, project|
  #     begin
  #       fog.action_server(instance_id)
  #       print '.'
  #     rescue StandardError => error
  #       "Couldn't #{action} #{name} in project #{project}: #{error.message}"
  #     end
  #   end
  # end
  # Here I am trying to pass as an argumnent part of the name of the unpause_server method
  # so this function can replace line 114-121 and 123-131
  def toggle_instances!(state)
    fog = OpenStackConnection.compute
    instances = projects.collect do |project|
      cached_servers.select{|server| server['tenant_id'] == project.uuid}.map{|server| [server['id'], server['name'], project.name]}
    end.flatten
    if state
      instances.each do |instance_id, name, project|
        begin
          fog.unpause_server(instance_id)
          print '.'
        rescue StandardError => error
          "Couldn't unpause #{name} in project #{project}: #{error.message}"
        end
      end
    else
      instances.each do |instance_id, name, project|
        begin
          fog.pause_server(instance_id)
          print '.'
        rescue StandardError => error
          "Couldn't pause #{name} in project #{project}: #{error.message}"
        end
      end
    end
  end
end
