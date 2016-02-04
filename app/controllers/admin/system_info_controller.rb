class Admin::SystemInfoController < AdminBaseController
  def index
    @system_info = Rails::Info.to_html
  end
end