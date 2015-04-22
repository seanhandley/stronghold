require 'digest/sha1'
require 'honeybadger'

# Variable      Name Description
#
# name          Client name.
# password      Client password. Usually a good indicator of identity. Security implications are discussed below.
# company       Company name which the client inputs.
# email         Client's email address.
# address       Client's postal address.
# phone         Client's phone number.
# ip            Client's registration IP address.
# hostname      Hostname for server clients.
# accountuser   Hosting account username.
# accountpass   Hosting account password.
# domain        Domain name of the hosting client.
# payment       Payment processor identification, e.g. paypal email address.
# ccname        Name on credit card
# ccnumber      Credit card number
module FraudRecord
  def self.query(args={})
    processed_args = process_args(args).merge!('_action' => 'query',
                                            '_api'    => Rails.application.secrets.fraud_record_key)
    response = conn.get '/api/', processed_args
    value, count, reliability, _ = *Hash.from_xml(response.body)['report'].split('-')
    puts value
    puts count
    puts reliability
  rescue StandardError => e
    puts e.inspect
    Honeybadger.notify(e)
    return nil
  end

  private

  def self.conn
    Faraday.new(:url => FRAUD_RECORD_ARGS[:host], ssl: { verify: false }) do |faraday|
      faraday.request  :url_encoded
      # faraday.response :logger    
      faraday.adapter  Faraday.default_adapter
    end
  end

  def self.process_args(args)
    args.inject({}) do |acc, v|
      acc[v[0]] = salt_and_hash(v[1].gsub(/\s/,'').downcase)
      acc
    end
  end

  def self.salt_and_hash(value)
    32_000.times do
      value = Digest::SHA1.hexdigest("fraudrecord-#{value}")
    end
    value
  end
end
