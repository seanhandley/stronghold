class Support::RoleUsersController < SupportBaseController

  skip_authorization_check

  before_filter :get_role_user

  def destroy
    if @role_user.destroy
      redirect_to support_roles_path(tab: 'roles')
    else
      redirect_to support_roles_path(tab: 'roles'), notice: @role_user.errors.full_messages.join
    end
  end

  private

  def get_role_user
    @role_user = RoleUser.where(role_id: params[:role_id], user_id: params[:user_id]).first
    @role_user.current_user = current_user
  end
end