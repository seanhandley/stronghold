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

  private

  def update_params
    params.require(:organization).permit(:name, :time_zone, :billing_address1, :billing_address2,
                                         :billing_postcode, :billing_city, :billing_country,
                                         :phone)
  end

  def check_organization
    raise ActionController::RoutingError.new('Not Found') unless current_user.organization.id = params[:id]
  end

  def check_power_user
    raise ActionController::RoutingError.new('Not Found') unless current_user.power_user?
  end

end