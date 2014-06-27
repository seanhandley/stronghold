class Support::RoleUsersController < SupportBaseController

  load_and_authorize_resource class_name: 'Role'

  def destroy
    @role_user = RoleUser.where(destroy_params).first
    @role_user.current_user = current_user
    if @role_user.destroy
      redirect_to support_roles_path(tab: 'roles')
    else
      redirect_to support_roles_path(tab: 'roles'), notice: @role_user.errors.full_messages.join
    end
  end

  def create
    @role_user = RoleUser.new(create_params)
    if @role_user.save
      javascript_redirect_to support_roles_path(tab: 'roles')
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => @role_user} }
      end
    end
  end

  private

  def create_params
    params.require(:role_user).permit(:user_id, :role_id)
  end

  def destroy_params
    params.permit(:user_id, :role_id)
  end
end