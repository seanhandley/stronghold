class Terminal
  def initialize(credentials)
    @credentials = DOCKER_ARGS.merge(credentials)
  end

  def run_command(command)
    command = <<-EOS
      openstack #{command} --os-auth-type token --os-auth-url #{@credentials[:auth_url]}
      --os-token #{Terminal.get_project_tokens(@credentials[:user])[@credentials[:tenant_name]]}
      --os-tenant-name #{@credentials[:tenant_name]} --os-username #{@credentials[:user].email}
    EOS
    command.strip!
    command.gsub! "\n", ""

    container = image.run(command)
    stdout, stderr = container.tap(&:start).attach(logs: true)
    [stderr.empty?, [stdout,stderr].flatten.join]
  ensure
    container&.delete(:force => true)
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
