# This Sanity module is responsible for
module Sanity
  def self.check
    results = current_sanity_state.dup
    key = "previous_sanity_state"
    cache = Rails.cache
    previous_results = cache.read(key)
    if previous_results
      duplicates = compare_sanity_states(previous_results, results)
      cache.write(key, results, expires_in: 3.days)
      return duplicates.merge(:sane => duplicates.values.none?(&:present?))
    else
      cache.write(key, results, expires_in: 3.days)
      return {sane: true}
    end
  end

  def self.current_sanity_state
    {
      missing_instances: build_missing_collection_hash(missing_instances, :instance_id),
      missing_volumes: build_missing_collection_hash(missing_volumes, :volume_id),
      missing_images: build_missing_collection_hash(missing_images, :image_id),
      new_instances: Hash[new_instances.collect{|key,value| [key, {name: value['name'], project_id: value['tenant_id']}]}]
    }
  end

  def self.missing_instances
    Billing::Instance.active.reject do |instance|
      if !live_instances.include?(instance.instance_id)
        false
      else
        from = instance.instance_states.order('recorded_at').first&.recorded_at
        to   = instance.instance_states.order('recorded_at').last&.recorded_at
        if from.nil? or to.nil?
          false
        elsif !instance.terminated_at && !live_instances[instance.instance_id]
          instance.update_attributes(terminated_at: to)
          true
        else
          check_instance_state(live_instances[instance.instance_id]['status'].downcase,
                     instance.fetch_states(from, to).last.state.downcase)
        end
      end
    end
  end

  def self.new_instances
    live_instances.reject do |instance,props|
      Billing::Instance.find_by_instance_id(instance) || props['status'] == 'error'
    end
  end

  def self.missing_volumes
    Billing::Volume.active.reject do |volume|
      live_volumes.include?(volume.volume_id)
    end
  end

  def self.missing_images
    Billing::Image.active.reject do |image|
      live_images.include?(image.image_id)
    end
  end

  def self.build_missing_collection_hash(collection, id_method)
    Hash[collection.collect{|item| [item.send(id_method), {name: item.name, project_id: item.project_id}]}]
  end

  def self.compare_sanity_states(previous_results, results)
    Hash[results.collect do |key,value|
      [key, value.select{|item,_| previous_results[key][item]}]
    end]
  end

  def self.notify!(data)
    msg = Mailer.usage_sanity_failures(data).text_part.to_s
    ignore = "Content-Type: text/plain;\r\n charset=UTF-8\r\nContent-Transfer-Encoding: 7bit\r\n\r\n"
    msg.gsub! ignore, ''
    Notifications.notify(:sanity_check, msg)
  end

  def self.live_instances
    Hash[LiveCloudResources.servers.collect{|server| [server['id'], {'status' => server['status'].downcase, 'name' => server['name'], 'tenant_id' => server['tenant_id']}]}]
  end

  def self.live_volumes
    LiveCloudResources.volumes.collect{|volume| volume['id']}
  end

  def self.live_images
    LiveCloudResources.images.collect{|image| image['id']}
  end

  def self.check_instance_state(live, recorded)
    if live.include?('rescue')
      return recorded.include?('rescue')
    elsif live.include?('shutoff')
      return ['shutoff', 'stopped'].include?(recorded)
    else
      live == recorded
    end
  end
end
