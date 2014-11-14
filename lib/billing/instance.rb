module Billing
  module Instance
    def self.billable_hours(tenant_id, size, image_id, from, to)
      timestamp_format = "%Y-%m-%dT%H:%M:%S" # 2014-11-14T11:37:09
      options = [{'field' => 'timestamp', 'op' => 'ge', 'value' => from.strftime(timestamp_format)},
                 {'field' => 'timestamp', 'op' => 'lt', 'value' => to.strftime(timestamp_format)},
                 {'field' => 'project_id', 'value' => tenant_id, 'op' => 'eq'}]
      results = Fog::Metering.new(OPENSTACK_ARGS).get_samples("instance:#{size}", options).body
      puts results
      count = 0
      total = results.group_by{|r| r['resource_id']}.collect do |instance, metrics|
        ((metrics.count.to_f * multiplier.to_f) / 60.0).ceil
      end
      # puts "Number of instances for period: #{total.count}"
      total.sum
    end
  end
end
