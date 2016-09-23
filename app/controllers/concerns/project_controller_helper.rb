module ProjectControllerHelper
  extend ActiveSupport::Concern

  included do
    before_filter :fetch_project,  only: [:update, :destroy]
    before_filter :fetch_projects, only: [:index]
    before_filter :get_organization
  end

  def create
    @project = @organization.projects.create(name: project_params[:name])
    create_project(@project)
  end

  def update
    ajax_response(@project, :update, redirect_path, user_project_roles_attributes.merge(name: project_params[:name], quota_set: quota_params.to_h))
  end

  def destroy
    if @project.destroy_unless_primary
      redirect_to redirect_path, notice: "Project removed successfully"
    else
      redirect_to redirect_path, alert: "Couldn't delete project"
    end
  end

  def project_params
    params.require(:project).permit(:name, :users => Hash[current_organization.users.map{|u| [u.id.to_s, true]}])
  end

  def quota_params
    params.require(:quota).permit(:compute => StartingQuota['standard']['compute'].keys.map(&:to_sym),
      :volume => StartingQuota['standard']['volume'].keys.map(&:to_sym),
      :network => StartingQuota['standard']['network'].keys.map(&:to_sym))
  end

  def fetch_project
    @project ||= Project.find(params[:id])
  end

  def fetch_projects
    @projects ||= Project.where(organization: current_organization).includes(:users)
  end

  def create_project(project)
    begin
      project.save!
      project.update!(user_project_roles_attributes)
      project.update_attributes!(quota_set: quota_params.to_h)
      project.enable!
      javascript_redirect_to support_projects_path
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => project }, status: :unprocessable_entity }
      end
    end
  end

end
