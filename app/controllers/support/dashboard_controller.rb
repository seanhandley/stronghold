class Support::DashboardController < SupportBaseController

  skip_authorization_check

  def current_section
    'cloud'
  end

  def index
  end

  def regenerate_ceph_credentials
    current_user.refresh_ec2_credentials!
    render json: {success: true, credentials: current_user.ec2_credentials}
  rescue StandardError => e
    Honeybadger.notify(e)
    render json: {success: false, message: e.message}
  end

end
