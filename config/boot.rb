ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

defaults = File.expand_path('../../.defaults', __FILE__)
if File.exists?(defaults)
  File.readlines(defaults).each_with_index do |line, n|
    begin
      next unless line.strip.length > 0
      values = line.split("=")
      ENV[values[0].split(' ')[1].strip] = values[1].strip.gsub!("\"","")
    rescue StandardError
      puts "Couldn't parse line #{n+1} of .defaults"
    end
  end
end
