class Support::TerminalController < SupportBaseController

  before_action -> { authorize! :read, :cloud }

  def current_section
    'terminal'
  end

  def index
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
        render json: Terminal::OpenStackCommand.sub_commands.values.flatten.uniq.sort.to_json
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
end
