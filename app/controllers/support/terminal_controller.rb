class Support::TerminalController < SupportBaseController

  before_action -> { authorize! :read, :cloud }
  before_action -> { slow_404 unless current_user.can_use_terminal? }

  def current_section
    'terminal'
  end

  def index
    @projects = current_user.projects
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

  def terminal_tab_complete
    respond_to do |format|
      format.js {
        render json: Terminal::OpenStackCommand.sub_commands.values.flatten.uniq.to_json
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
