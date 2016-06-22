class Support::DashboardController < SupportBaseController

  skip_authorization_check

  def current_section
    'cloud'
  end

  def index
    if params[:show_graphs]
      respond_to do |format|
        format.html { render template: 'support/dashboard/graphs' }
      end
    else
      respond_to do |format|
        format.js {
          render json: {instance_count: instance_count(live_servers), object_usage: object_usage}
        }
        format.html {
          @instance_count = instance_count(Rails.cache.fetch("live_servers_dashboard") || [])
          @object_usage = Rails.cache.fetch("object_usage_#{current_organization.primary_project.id}") || '0'
        }
      end
    end
  end

  def regenerate_ceph_credentials
    current_user.refresh_ec2_credentials!
    render json: {success: true, credentials: current_user.ec2_credentials}
  rescue StandardError => e
    Honeybadger.notify(e)
    render json: {success: false, message: e.message}
  end

  private

  def instance_count(servers)
    servers.select{|s| current_organization.projects.map(&:uuid).include?(s['tenant_id'])}.count
  end

  def live_servers
    Rails.cache.fetch("live_servers_dashboard", expires_in: 5.minutes) do
      OpenStackConnection.compute.list_servers_detail(all_tenants: true).body['servers']
    end
  end

  def object_usage
    Rails.cache.fetch("object_usage_#{current_organization.primary_project.id}", expires_in: 4.hours) do
      ((Ceph::Usage.kilobytes_for(current_organization.primary_project.uuid) / 1024.0) / 1024.0).round(2) rescue 0
    end
  end

end
