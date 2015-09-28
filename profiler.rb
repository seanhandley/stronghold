require_relative './config/environment'

require 'ruby-prof'

# Profile the code
RubyProf.start

organization = Organization.find(321)
ud = UsageDecorator.new(organization)
ud.usage_data(from_date: Time.now.beginning_of_month, to_date: Time.now)

result = RubyProf.stop

# Print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)