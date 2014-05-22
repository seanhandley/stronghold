class Support::RolesController < SupportBaseController

  load_and_authorize_resource
  before_filter :find_role

  def index
    @roles = Role.all
    @users = User.all
  end

  def update
    @role.update!(role_params)
    respond_to do |format|
      format.json { head :ok }
      format.html
    end
  end

  private

  def find_role
    @role = Role.find(params[:id]) if params[:id]
  end

  def role_params
    params.require(:role).permit(:name, {:permissions => []}).
      merge(params[:role].include?(:permissions) ? {} : {permissions: []})
  end
  
end