class Support::RoleUsersController < SupportBaseController

  skip_authorization_check

  before_filter :get_user, :get_role

  def destroy
    if @user.roles.delete(@role)
      redirect_to support_roles_path(tab: 'roles')
    else
      redirect_to support_roles_path(tab: 'roles'), notice: "Couldn't remove."
    end
  end

  private

  def get_user
    @user = User.find(params[:user_id]) if params[:user_id]
  end

  def get_role
    @role = Role.find(params[:role_id]) if params[:role_id]
  end
end