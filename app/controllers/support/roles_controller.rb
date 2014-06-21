class Support::RolesController < SupportBaseController

  load_and_authorize_resource param_method: :role_params
  
  before_filter :find_role, :find_organization

  def current_section
    'roles'
  end

  def index
    @roles = @organization.roles
    @users = @organization.users
    @new_role = Role.new
  end

  def update
    @role.update!(role_params)
    respond_to do |format|
      format.json { head :ok }
      format.html
    end
  end

  def create
    @role = @organization.roles.create(role_params)
    if @role.save
      javascript_redirect_to(support_roles_path)
    else
      respond_to do |format|
        format.json { head :ok }
        format.html
      end
    end
  end

  private

  def find_role
    @role = Role.find(params[:id]) if params[:id]
  end

  def find_organization
    @organization = current_user.organization
  end

  def role_params
    params.require(:role).permit(:name, {:permissions => []}).
      merge(params[:role].include?(:permissions) ? {} : {permissions: []})
  end
  
end