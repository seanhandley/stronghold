require_relative './config/environment'

require 'ruby-prof'

# Profile the code
RubyProf.start

Billing::sync!

result = RubyProf.stop

# Print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)