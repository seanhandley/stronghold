class Support::TerminalController < SupportBaseController

  skip_authorization_check
  before_action -> { slow_404 unless user_can_use_terminal? }
  before_action -> { authorize! :read, :cloud }


  def index
    @projects = current_organization.projects
  end

  def run_command
    success, message = fetch_response
    respond_to do |format|
      format.js {
        render json: {
          success: success,
          message: message
        }.to_json
      }
    end
  end

  private

  def run_command_params
    params.permit(:command, :project)
  end

  def fetch_response
    begin
      Terminal.new(credentials).run_command run_command_params[:command]
    rescue StandardError => e
      [false, e.message]
    end
  end

  def credentials
    {
      tenant_name: run_command_params[:project],
      user: current_user
    }
  end

  def user_can_use_terminal?
    current_user.staff? || [49, 733].include?(current_user.organization_id)
  end
end
