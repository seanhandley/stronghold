class Terminal
  def initialize(credentials)
    @credentials = DOCKER_ARGS.merge(credentials)
    command = ["bash", "-c", initialize_command]
    @container = Docker::Container.create('Image' => @credentials[:openstack_client_image], 'Cmd' => command, 'Tty' => true, 'OpenStdin' => true)
    start
  end

  def initialize_command
    command = <<-EOS
      openstack --os-auth-type token --os-auth-url #{@credentials[:auth_url]}
      --os-token #{Terminal.get_project_tokens(@credentials[:user])[@credentials[:tenant_name]]}
      --os-tenant-name #{@credentials[:tenant_name]} --os-username #{@credentials[:user].email}
    EOS
    command.strip!
    command.gsub! "\n", ""
    p command
    command
  end

  def start
    Thread.new do
      loop do
        begin
          @container.tap(&:start).attach(stream: true, tty: true) { |stream, _| print stream }
        ensure
          destroy
        end
      end
    end
  end

  def run_command(command)
    stdout, stderr = @container.attach(stdin: StringIO.new("#{command}\n"), tty: true, logs: true)
    [stderr.empty?, [stdout,stderr].flatten.join]
    #[true, 'done']
  end

  # docker run -i -t ... sh -c "exec >/dev/tty 2>/dev/tty </dev/tty && /usr/bin/screen -s /bin/bash"

  def destroy
    @container&.delete(:force => true)
  end

  def self.fetch(credentials)
    key = fetch_key(credentials)
    Rails.application.config.terminals.fetch(key) { Rails.application.config.terminals[key] = Terminal.new(credentials) }
  end

  def self.fetch_key(credentials)
    "saved_terminal_#{credentials[:user].id}_#{credentials[:tenant_name]}"
  end

  def self.get_project_tokens(user, password=nil)
    Rails.cache.fetch("os_tokens_user_#{user.id}", expires_in: 4.hours, force: !!password) do
      Hash[user.organization.projects.map {|project|
        begin
          args = OPENSTACK_ARGS.dup
          args.merge!(:openstack_username      => user.email,
                      :openstack_project_name  => project.reference,
                      :openstack_api_key       => password)
          [project.reference, Fog::Identity.new(args).unscoped_token]
        rescue Excon::Errors::Unauthorized, NameError => e
          nil
        end
      }.compact]
    end
  end

  private

  def image
    Docker::Image.get @credentials[:openstack_client_image]
  end
end
