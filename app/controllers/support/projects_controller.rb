class Support::ProjectsController < SupportBaseController
  include UserProjectRoleHelper

  skip_authorization_check

  before_filter :check_power_user_and_cloud_and_unrestricted
  before_filter :fetch_project, only: [:update, :destroy]

  def index
    @projects = Project.where(organization: current_organization).includes(:users)
  end

  def create
    @project = current_organization.projects.create(name: project_params[:name])
    begin
      @project.save!
      @project.update!(user_project_roles_attributes)
      @project.update_attributes!(quota_set: quota_params.to_h)
      @project.enable!
      javascript_redirect_to support_projects_path
    rescue ActiveRecord::RecordInvalid
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => @project }, status: :unprocessable_entity }
      end
    end
  end

  def update
    ajax_response(@project, :update, support_projects_path, user_project_roles_attributes.merge(name: project_params[:name], quota_set: quota_params.to_h))
  end

  def destroy
    if @project.destroy_unless_primary
      redirect_to support_projects_path, notice: "Removed project successfully"
    else
      redirect_to support_projects_path, alert: "Couldn't delete project"
    end
  end

  private

  def fetch_project
    @project ||= Project.find(params[:id])
  end

  def check_power_user_and_cloud_and_unrestricted
    raise ActionController::RoutingError.new('Not Found') unless current_user.power_user? && current_organization.cloud? && !current_organization.limited_storage?
  end

  def project_params
    params.require(:project).permit(:name, :users => Hash[current_organization.users.map{|u| [u.id.to_s, true]}])
  end

  def quota_params
    params.require(:quota).permit(:compute => StartingQuota['standard']['compute'].keys.map(&:to_sym),
      :volume => StartingQuota['standard']['volume'].keys.map(&:to_sym),
      :network => StartingQuota['standard']['network'].keys.map(&:to_sym))
  end

end