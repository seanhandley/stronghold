class Support::OrganizationsController < SupportBaseController

  skip_authorization_check

  before_filter :check_power_user

  def current_section
    action_name == 'index' ? '' : 'roles'
  end

  def index
    @organization = current_organization
    @users_emails = @organization.users.map{|u| u.email}
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
        format.js { render :template => "shared/dialog_errors", :locals => {:object => current_organization }, status: :unprocessable_entity }
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
      users = current_organization.admin_users
      current_organization.transition_to!(:closed, user_email: current_user.email, auth_token: session['token'])
      Mailer.goodbye(users).deliver_later
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
                                         :phone, :billing_contact, :technical_contact)
  end

  def reauthorise_params
    params.permit(:password)
  end

  def check_organization
    slow_404 unless current_organization.id = params[:id]
  end

  def check_power_user
    slow_404 unless current_user.power_user?
  end

end
