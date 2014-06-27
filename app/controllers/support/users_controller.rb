class Support::UsersController < SupportBaseController

  skip_authorization_check

  def current_section
    'roles'
  end

  def index
    render template: 'support/users/profile'
  end

  def update
    check_user
    if current_user.update!(update_params)
      javascript_redirect_to support_profile_path
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => current_user } }
      end
    end
  end

  private

  def update_params
    params.require(:user).permit(:first_name, :last_name, :email,
                                 :password, :password_confirmation)
  end

  def check_user
    raise ActionController::RoutingError.new('Not Found') unless current_user.id = params[:id]
  end

end