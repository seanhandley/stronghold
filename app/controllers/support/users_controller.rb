class Support::UsersController < SupportBaseController

  skip_authorization_check
  authorize_resource class_name: 'User', only: [:destroy]

  def index
    @user = current_user
    render template: 'support/users/profile'
  end

  def update
    check_user
    if current_user.update(update_params)
      respond_to do |format|
        format.js {
          reauthenticate(update_params[:password]) if update_params[:password].present?
          render :template => "shared/dialog_success", :locals => {message: 'Changes saved', object: current_user }
        }
      end
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => current_user } }
      end
    end
  end

  def destroy
    @user = User.find destroy_params[:id]
    if @user.destroy
      respond_to do |format|
        format.js {
          javascript_redirect_to support_roles_path
        }
      end
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => @user } }
      end
    end
  end

  private

  def update_params
    params.require(:user).permit(:first_name, :last_name,
                                 :password)
  end

  def destroy_params
    params.permit(:id)
  end

  def check_user
    raise ActionController::RoutingError.new('Not Found') unless current_user.id = params[:id]
  end

end