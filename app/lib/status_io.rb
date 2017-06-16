require 'honeybadger'
# This StatusIO module is responsible for
module StatusIO
  class << self
    def add_subscriber(email)
      body = {
               "meth" => "email",
               "address" => email,
               "silent" => '1'
             }.merge("statuspage_id" => Rails.application.secrets.status_io_page_id).to_json
      post '/v2/subscriber/add', body
    rescue StandardError => e
      Honeybadger.notify(e)
      raise
    end

    def remove_subscriber(email)
      subscriber_id = StatusIO.subscribers[email].try(:[], '_id')
      return true unless subscriber_id
      delete "/v2/subscriber/remove/#{Rails.application.secrets.status_io_page_id}/#{subscriber_id}"
    rescue StandardError => e
      Honeybadger.notify(e)
      raise
    end

    def subscribers
      subs = JSON.parse(get("/v2/subscriber/list/#{Rails.application.secrets.status_io_page_id}").body)
      Hash[subs['result']['email'].map{|entry| [entry['address'], entry]}]
    end

    def active_incidents
      Rails.cache.fetch("status_io_active_incidents", expires_in: 15.minutes) do
        list_items('incident', 'active_incidents')
      end
    end

    def active_maintenances
      Rails.cache.fetch("status_io_active_maintenances", expires_in: 15.minutes) do
        list_items('maintenance', 'active_maintenances')
      end
    end

    def upcoming_maintenances
      Rails.cache.fetch("status_io_upcoming_maintenances", expires_in: 15.minutes) do
        list_items('maintenance', 'upcoming_maintenances')
      end
    end

    private

    def conn
      Faraday.new(:url => STATUS_IO_ARGS[:host]) do |faraday|
        faraday.request  :url_encoded
        faraday.adapter  Faraday.default_adapter
      end
    end

    def get(url)
      conn.get do |req|
        req.url url
        req.headers = shared_headers
      end
    end

    def delete(url)
      conn.delete do |req|
        req.url url
        req.headers = shared_headers
      end
    end

    def post(url, body)
      conn.post do |req|
        req.url url
        req.headers = shared_headers
        req.body = body
      end
    end

    def shared_headers
      {
        'Content-Type' => 'application/json',
        'API-ID'       => Rails.application.secrets.status_io_id,
        'API-KEY'      => Rails.application.secrets.status_io_key,
        'x-api-id'     => Rails.application.secrets.status_io_id,
        'x-api-key'    => Rails.application.secrets.status_io_key
      }
    end

    def list_items(key, filter)
      resp = get "/v2/#{key}/list/#{Rails.application.secrets.status_io_page_id}"
      resp = JSON.parse(resp.body)
      raise resp['status']['message'] if resp['status']['error'] == 'yes'
      resp['result'][filter]
    rescue StandardError => e
      Honeybadger.notify(e)
      []
    end
  end
end
