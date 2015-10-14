class Support::OrganizationsController < SupportBaseController
  include OffboardingHelper

  skip_authorization_check

  before_filter :check_power_user

  def current_section
    'roles'
  end

  def index
    @organization = current_organization
    render template: 'support/organizations/organization'
  end

  def update
    check_organization
    if current_organization.update(update_params)
      respond_to do |format|
        format.js { render :template => "shared/dialog_success", :locals => {:object => current_organization, :message => "Saved" } }
      end
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => current_organization } }
      end
    end
  end

  def reauthorise  
    if reauthenticate(reauthorise_params[:password])
      render json: {success: true }
    else
      render json: {success: false }
    end
  end

  # Close this user's account
  def close
    if reauthenticate(reauthorise_params[:password]) && !current_user.staff?
      Notifications.notify(:account_alert, "#{current_organization.name} (REF: #{current_organization.reference}) has requested account termination.")
      creds = {:openstack_username => current_user.email,
               :openstack_api_key  => nil,
               :openstack_auth_token => session[:token],
               :openstack_tenant   => current_organization.primary_tenant.reference }
      current_organization.tenants.each do |tenant|
        offboard(tenant, creds)
        begin
          Ceph::User.update('uid' => tenant.uuid, 'suspended' => true)
        rescue Net::HTTPError => e
          Honeybadger.notify(e)
        end
      end
      current_organization.disable!
      Mailer.goodbye(current_organization.admin_users).deliver_later
      reset_session
      render :goodbye
    else
      redirect_to support_edit_organization_path, alert: 'Your password was wrong. Account termination has been aborted.'
    end
  end

  private

  def update_params
    params.require(:organization).permit(:name, :time_zone, :billing_address1, :billing_address2,
                                         :billing_postcode, :billing_city, :billing_country,
                                         :phone)
  end

  def reauthorise_params
    params.permit(:password)
  end

  def check_organization
    raise ActionController::RoutingError.new('Not Found') unless current_organization.id = params[:id]
  end

  def check_power_user
    raise ActionController::RoutingError.new('Not Found') unless current_user.power_user?
  end

end