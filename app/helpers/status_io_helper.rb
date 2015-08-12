module StatusIoHelper
  def status_io_url(key, id)
    "http://status.datacentred.io/pages/#{key}/#{Rails.application.secrets.status_io_page_id}/#{id}"
  end
end