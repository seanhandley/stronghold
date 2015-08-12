module StatusIO
  def self.add_subscriber(email)
    conn.post do |req|
      req.url '/v2/subscriber/add'
      req.headers['Content-Type'] = 'application/json'
      req.headers['API-ID'] = Rails.application.secrets.status_io_id
      req.headers['API-KEY'] = Rails.application.secrets.status_io_key
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
      req.headers['API-ID'] = Rails.application.secrets.status_io_id
      req.headers['API-KEY'] = Rails.application.secrets.status_io_key
    end
    JSON.parse(resp.body)['result'][filter]
  end

  def self.active_incidents
    list_items('incident', 'active_incidents')
  end

  def self.active_maintenances
    list_items('maintenance', 'active_maintenances')
  end

  def self.upcoming_maintenances
    list_items('maintenance', 'upcoming_maintenances')
  end

  private

  def self.conn
    Faraday.new(:url => STATUS_IO_ARGS[:host]) do |faraday|
      faraday.request  :url_encoded
      faraday.adapter  Faraday.default_adapter
    end
  end
end
