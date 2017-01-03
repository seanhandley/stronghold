class Support::DashboardController < SupportBaseController
  include UsageAlertHelper
  skip_authorization_check

  def current_section
    'cloud'
  end

  def index
    @alerts_message = alerts_message
  end

  def regenerate_ceph_credentials
    current_user.refresh_ec2_credentials!
    render json: {success: true, credentials: current_user.ec2_credentials}
  rescue StandardError => e
    Honeybadger.notify(e)
    render json: {success: false, message: e.message}
  end

end
