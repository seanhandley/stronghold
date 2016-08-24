class Support::TerminalController < SupportBaseController

  skip_authorization_check

  before_action -> { slow_404 unless current_user.staff? }

  def index
    @projects = current_organization.projects
  end

  def run_command
    respond_to do |format|
      format.js {
        render json: {
          response: fetch_response
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
      e.message
    end
  end

  def credentials
    {
      tenant_name: run_command_params[:project],
      user: current_user
    }
  end
end
