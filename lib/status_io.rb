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

  private

  def self.conn
    Faraday.new(:url => STATUS_IO_ARGS[:host]) do |faraday|
      faraday.request  :url_encoded
      faraday.adapter  Faraday.default_adapter
    end
  end
end
