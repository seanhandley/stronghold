module Support
  class DashboardController < SupportBaseController
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

    def regenerate_datacentred_api_credentials
      slow_404 unless current_user.staff?
      secret_key = current_user.refresh_datacentred_api_credentials!
      render json: {success: true, secret_key: secret_key}
    rescue StandardError => e
      Honeybadger.notify(e)
      render json: {success: false, message: e.message}
    end
  end
end
