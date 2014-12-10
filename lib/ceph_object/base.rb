require 'aws/s3'

module CephObject

  # Handle various object types available via Ceph
  #
  # Note: Debugging can be carried out by calling self.send(:obj).inspect
  #
  class Base

    def self.create(params)
      request(:put, path, params)
    end

    def self.destroy(params)
      request(:delete, path, params)
    end

    def self.exists?(params)
      request(:get, path, params)
    rescue Net::HTTPError => e
      raise e unless e.message.include?('NoSuchKey')
      return false
    end
    
    def self.request(verb, path, params)
      conn
      response = AWS::S3::Base.request(verb, "#{path}#{params.to_query}", options)
      if response.code == 200
        if response.body.length > 0
          JSON.parse(response.body)
        else
          true
        end
      else
        raise Net::HTTPError.new(JSON.parse(response.body)['Code'], response)
      end
    end

    private

    def self.options
      {use_ssl: true}
    end

    def self.conn
      args = CEPH_ARGS.dup
      Kernel.silence_warnings do
        AWS::S3.const_set('DEFAULT_HOST', args[:api_url])
      end
      
      AWS::S3::Base.establish_connection!(
        :access_key_id     => args[:ceph_token], 
        :secret_access_key => args[:ceph_key]
      )
    end
  end
end