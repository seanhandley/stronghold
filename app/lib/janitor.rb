module Janitor
  def self.sweep(sanity_data, dry_run: false)
    sweep_instances(sanity_data[:missing_instances].keys, dry_run: dry_run)
  end

  private

  def self.sweep_instances(instance_ids, dry_run: false)
    instance_ids.each do |id|
      instance = Billing::Instance.find_by_instance_id(id)
      if absent_from_live_resources?('servers', id)
        if instance.total_billable_seconds == 0
          if instance.raw_billable_states.none?
            unless dry_run
              instance.instance_states.delete_all
              instance.delete
            end
            logger.info "Instance #{id} is absent from hypervisor and has no billable time. Deleted."
          else
            logger.info "Instance #{id} has billable history: #{instance.raw_billable_states}. Please check ceilometer"
          end
        else
          unless dry_run
            instance.instance_states.create! recorded_at: Time.now,
                                             state:       'deleted',
                                             event_name:  'compute.instance.detected_absence',
                                             message_id:  SecureRandom.hex,
                                             sync_id:     Billing::Sync.last.id,
                                             flavor_id:   instance.instance_flavor.flavor_id
            instance.reindex_states
          end
          logger.info "Instance #{id} is missing delete event. Automatically added one."
        end
      end
    end
  end

  def self.absent_from_live_resources?(kind, uuid)
    LiveCloudResources.send(kind).map{|x| x['id']}.exclude?(uuid)
  end

  def self.logger
    if Rails.env.production?
      ::Logger.new("/var/log/rails/stronghold/janitor.log")
    else
      Rails.logger
    end
  end
end
