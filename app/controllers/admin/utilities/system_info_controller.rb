class Admin::Utilities::SystemInfoController < UtilitiesBaseController
  def index
    @system_info = Rails::Info.to_html
  end
end
