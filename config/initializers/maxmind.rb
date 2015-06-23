Maxmind.license_key = ENV['MAXMIND_LICENSE_KEY']
Maxmind::Request.default_request_type = 'standard'

require_relative '../../lib/fraud_check'