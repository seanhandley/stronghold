module StatusIO
  def self.add_subscriber(email)
    conn.post do |req|
      req.url '/v2/subscriber/add'
      req.headers['Content-Type'] = 'application/json'
      req.headers['API-ID'] = Rails.application.secrets.status_io_id
      req.headers['API-KEY'] = Rails.application.secrets.status_io_key
      req.headers['x-api-id'] = Rails.application.secrets.status_io_id
      req.headers['x-api-key'] = Rails.application.secrets.status_io_key
      req.body = {
                    "meth" => "email",
                    "address" => email,
                    "silent" => '1'
                  }.merge("statuspage_id" => Rails.application.secrets.status_io_page_id).to_json
    end
  end

  def self.list_items(key, filter)
    resp = conn.get do |req|
      req.url "/v2/#{key}/list/#{Rails.application.secrets.status_io_page_id}"
      req.headers['Content-Type'] = 'application/json'
      req.headers['x-api-id'] = Rails.application.secrets.status_io_id
      req.headers['x-api-key'] = Rails.application.secrets.status_io_key
    end
    resp = JSON.parse(resp.body)
    raise resp['status']['message'] if resp['status']['error'] == 'yes'
    resp['result'][filter]
  end

  def self.active_incidents
    Rails.cache.fetch("status_io_active_incidents", expires_in: 5.minutes) do
      list_items('incident', 'active_incidents')
    end
  end

  def self.active_maintenances
    Rails.cache.fetch("status_io_active_maintenances", expires_in: 5.minutes) do
      list_items('maintenance', 'active_maintenances')
    end
  end

  def self.upcoming_maintenances
    Rails.cache.fetch("status_io_upcoming_maintenances", expires_in: 5.minutes) do
      list_items('maintenance', 'upcoming_maintenances')
    end
  end

  private

  def self.conn
    Faraday.new(:url => STATUS_IO_ARGS[:host]) do |faraday|
      faraday.request  :url_encoded
      faraday.adapter  Faraday.default_adapter
    end
  end
end
