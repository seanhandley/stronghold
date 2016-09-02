require_relative "./terminal/open_stack_command"

class Terminal
  def initialize(credentials)
    @credentials = DOCKER_ARGS.merge(credentials)
  end

  def run_command(command)
    return [true, OpenStackCommand.help] if command.strip == 'help'
    return [true, OpenStackCommand.commands] if command.strip == 'commands'
    command = OpenStackCommand.new(command, @credentials)
    Terminal.logger.info command.to_s
    container = image.run(command.to_s)
    stdout, stderr = container.tap(&:start).attach(logs: true)
    [stderr.empty?, [stdout,stderr].flatten.join]
  ensure
    container&.delete(:force => true)
  end

  private

  def self.logger
    if Rails.env.production?
      ::Logger.new("/var/log/rails/stronghold/terminal_commands.log")
    else
      Rails.logger
    end
  end

  def image
    Docker::Image.get @credentials[:openstack_client_image]
  end
end
