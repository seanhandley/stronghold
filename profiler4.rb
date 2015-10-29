require_relative './config/environment'

require 'ruby-prof'

module Billing
  module Instances

    def self.usage(tenant_id, from, to)
      instances = []
      if tenant_id.present?
        instances = Billing::Instance.where(:tenant_id => tenant_id).active.to_a.compact
      else
        instances = Billing::Instance.all.includes(:instance_states).to_a.compact
      end
      instances = instances.collect do |instance|
        billable_seconds = seconds(instance, from, to)
        billable_hours = (billable_seconds / Billing::SECONDS_TO_HOURS).ceil
        instance_flavor = instance.instance_flavor
        {billable_seconds: billable_seconds,
                                       uuid: instance.instance_id,
                                       name: instance.name,
                                       tenant_id: instance.tenant_id,
                                       first_booted_at: instance.first_booted_at,
                                       latest_state: instance.latest_state(from,to),
                                       terminated_at: instance.terminated_at,
                                       rate: instance.rate,
                                       billable_hours: billable_hours,
                                       cost: cost(instance, from, to),
                                       arch: instance.arch,
                                       flavor: {
                                         flavor_id: instance.flavor_id,
                                         name: instance_flavor.name,
                                         vcpus_count: instance_flavor.vcpus,
                                         ram_mb: instance_flavor.ram,
                                         root_disk_gb: instance_flavor.disk,
                                         rate: instance_flavor.rate},
                                       image: {
                                         image_id: instance.image_id,
                                         name: instance.instance_image ? instance.instance_image.name : ''}
                                       }
      end
      instances.select{|instance| instance[:billable_seconds] > 0}
    end

    def self.cost(instance, from, to)
      puts "Working out cost for #{instance.instance_id}..."
      flavors = instance.fetch_states(from, to).collect(&:flavor_id)
      puts "Fetched flavours"
      if flavors.uniq.count > 1
        return split_cost(instance, from, to).nearest_penny
      else
        billable_seconds = seconds(instance, from, to)
        puts "calcuated total seconds"
        billable_hours   = (billable_seconds / Billing::SECONDS_TO_HOURS).ceil
        puts "calcuated total hours"
        return (billable_hours * instance.rate.to_f).nearest_penny
      end
      
    end

    def self.split_cost(instance, from, to)
      print "Working out split cost..."
      states = instance.fetch_states(from, to)
      puts "fetched states"
      previous_state = instance.instance_states.where('recorded_at < ?', from).order('recorded_at DESC').limit(1).first
      puts "got previous state"
      first_state = states.first
      last_state = states.last

      if states.any?
        if states.count > 1
          start = 0

          if previous_state
            if billable?(previous_state.state)
              print "Calculating start..."
              start = (first_state.recorded_at - from)
              start = start / Billing::SECONDS_TO_HOURS
              puts "done"
              start * previous_state.rate
            end
          end

          previous = states.first
          puts "doing the middle"
          middle = states.collect do |state|
            puts "  -> #{state.state}"
            difference = 0
            if billable?(previous.state)
              difference = state.recorded_at - previous.recorded_at
            end
            begin
              difference = difference / Billing::SECONDS_TO_HOURS
              difference * previous.rate
            ensure
              puts "ensure block called"
              previous = state
            end
          end.sum

          puts "done"

          ending = 0

          if(billable?(last_state.state))
            puts "calculating ending"
            ending = (to - last_state.recorded_at)
            ending = ending / Billing::SECONDS_TO_HOURS
            puts "done"
            ending * last_state.rate
          end

          return (start + middle + ending)
        else
          # Only one sample for this period
          if billable?(first_state.state)
            time = (to - first_state.recorded_at)
            time = time / Billing::SECONDS_TO_HOURS
            return time * first_state.rate
          else
            return 0
          end
        end
      else
        if previous_state && billable?(previous_state.state)
          time = (to - from)
          time = time / Billing::SECONDS_TO_HOURS
          return time * previous_state.rate
        else
          return 0
        end
      end
    end

    def self.seconds(instance, from, to)
      print "Working out billable seconds for #{instance.instance_id}..."
      states = instance.fetch_states(from, to)
      previous_state = instance.instance_states.where('recorded_at < ?', from).order('recorded_at DESC').limit(1).first
      first_state = states.first
      last_state = states.last

      if states.any?
        if states.count > 1
          start = 0

          if previous_state
            if billable?(previous_state.state)
              start = (first_state.recorded_at - from)
            end
          end

          previous = first_state
          middle = states.collect do |state|
            difference = 0
            if billable?(previous.state)
              difference = state.recorded_at - previous.recorded_at
            end
            previous = state
            difference
          end.sum

          ending = 0

          if(billable?(last_state.state))
            ending = (to - last_state.recorded_at)
          end
          return (start + middle + ending).round
        else
          # Only one sample for this period
          if billable?(first_state.state)
            return (to - first_state.recorded_at).round
          else
            return 0
          end
        end
      else
        if previous_state && billable?(previous_state.state) && instance.active?
          return (to - from).round
        else
          return 0
        end
      end
    end
  end
end

module Reports
  class UsageReport
    private

    def organizations
      Organization.where(test_account: false).includes(:tenants).select(&:cloud?)
    end
  end
end



# Profile the code
RubyProf.start

from = (Time.zone.now - 1.day).beginning_of_week
to = (Time.zone.now - 1.day).end_of_week
Reports::UsageReport.new(from, to).contents

result = RubyProf.stop

# Print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)