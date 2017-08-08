require 'fog/openstack'

module ExconConnection
  def self.config_load
    YAML.load_file("#{Rails.root}/config/excon.yml")[Rails.env].symbolize_keys!
  end
  def self.configuration
    @@config_cache ||= config_load
  end
end

ENV["EXCON_DEBUG"] = "1" if ExconConnection.configuration[:debug]

module Excon
  class StandardInstrumentor
    def self.format_log(params)
      if params.include?(:status)
        request_id = params[:headers].slice("X-Compute-Request-Id", "x-openstack-request-id", "X-Openstack-Request-Id").values.uniq.join(", ")
        ["[OpenStack] HTTP #{params[:status]} #{params[:reason_phrase]}", request_id].compact.join(" - ")
      else
        ["[OpenStack] #{params[:method]} #{params[:scheme]}://#{params[:host]}:#{params[:port]}#{[params[:path],(params[:query]&.to_query)].compact.join('?')}", params[:body]].compact.join(" => ")
      end
    end

    def self.instrument(name, params = {}, &block)
      params = params.dup
      logger.info(format_log(params)) unless params[:path] == "/v3/auth/tokens"
      yield if block_given?
    end

    def self.logger
      if Rails.env.production?
        ::Logger.new(ExconConnection.configuration[:log])
      else
        Rails.logger
      end
    end
  end
end

Excon.defaults[:connect_timeout] = 10
Excon.defaults[:write_timeout] = 180
Excon.defaults[:read_timeout] = 180

