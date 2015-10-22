require_relative './config/environment'

require 'ruby-prof'

def organizations
  Organization.active.shuffle
end

def organization_plus_tenants_and_billing_items(organization)
  Organization.where(id: organization.id).includes(
    :tenants => [
      :billing_storage_objects,
      :billing_ip_quotas,
      {
      billing_instances: :instance_states,
      billing_volumes: :volume_states,
      billing_images: :image_states,
      billing_external_gateways: :external_gateway_states,
      billing_ips: :ip_states
    }]
  ).first
end

def warm_cache(organization)
  ud = UsageDecorator.new(organization_plus_tenants_and_billing_items(organization))
  ud.usage_data(from_date: Time.now.beginning_of_month, to_date: Time.now)
end



# Profile the code
RubyProf.start

organizations.each_with_index do |organization, i|
  warm_cache(organization)
end

result = RubyProf.stop

# Print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)