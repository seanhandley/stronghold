settings = YAML.load_file("#{Rails.root}/config/elastic_search.yml")[Rails.env]
settings.deep_symbolize_keys!

es_params = { hosts: [settings[:connection]] }

if settings[:ssl][:use_client_cert]
  ssl_options = {
    ssl: {
      cert: OpenSSL::X509::Certificate.new(File.read(settings[:ssl][:certificate_file])),
      key:  OpenSSL::PKey::RSA.new(File.read(settings[:ssl][:key_file]), Rails.application.secrets.ssl_x509_passphrase)
    }
  }
  es_params.merge!(transport_options: ssl_options, adapter: :net_http_persistent)
end

ES_CLIENT = Elasticsearch::Client.new es_params
