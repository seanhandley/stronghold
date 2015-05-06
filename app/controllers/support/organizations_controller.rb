class Support::OrganizationsController < SupportBaseController

  skip_authorization_check

  before_filter :check_power_user

  def current_section
    'roles'
  end

  def index
    @organization = current_user.organization
    render template: 'support/organizations/organization'
  end

  def update
    check_organization
    if current_user.organization.update(update_params)
      respond_to do |format|
        format.js { render :template => "shared/dialog_success", :locals => {:object => current_user.organization, :message => "Saved" } }
      end
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => current_user.organization } }
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
      reset_session
      current_user.organization.disable!
      Hipchat.notify('Account Closure', 'Accounts', "#{current_user.organization.name} (REF: #{current_user.organization.name}) has requested account termination.", color: 'red')
      current_user.organization.tenants.each {|tenant| TerminateAccountJob.perform_later(tenant)}
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
    raise ActionController::RoutingError.new('Not Found') unless current_user.organization.id = params[:id]
  end

  def check_power_user
    raise ActionController::RoutingError.new('Not Found') unless current_user.power_user?
  end

end