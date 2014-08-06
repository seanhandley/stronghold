class Support::RolesController < SupportBaseController

  load_and_authorize_resource param_method: :role_params
  
  before_filter :find_role, :find_organization

  def current_section
    'roles'
  end

  def index
    @roles = @organization.roles
    @users = @organization.users
    @open_invites = @organization.invites.select(&:can_register?)
    @new_role = Role.new
    @new_invite = Invite.new
  end

  def update
    renamed = @role.name != role_params[:name]
    @role.update!(role_params)
    respond_to do |format|
      format.js {
        if renamed
          javascript_redirect_to support_roles_path(tab: 'roles')
        else
          head :ok
        end
      }
      format.html
    end
  end

  def create
    @role = @organization.roles.create(role_params)
    if @role.save
      javascript_redirect_to support_roles_path(tab: 'roles')
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => @role } }
      end
    end
  end

  def destroy
    if @role.destroy
      redirect_to support_roles_path(tab: 'roles')
    else
      redirect_to support_roles_path(tab: 'roles'), notice: @role.errors.full_messages.join
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