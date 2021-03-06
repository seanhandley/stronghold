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

  class OpenStackCommandError < StandardError ; end

  class OpenStackCommand
    attr_reader :sub_command, :project_name, :project_uuid, :user, :auth_url

    def initialize(sub_command, credentials)
      @sub_command  = sub_command.gsub(/\s+/," ").strip
      @credentials  = credentials
      @project_name = credentials[:tenant_name]
      @project_uuid = Project.find_by_name(project_name).uuid
      @user         = credentials[:user]
      @auth_url     = credentials[:auth_url]

      raise(OpenStackCommandError, "Command '#{sub_command}' is unknown or unavailable. Type 'commands' to see available commands.") unless is_allowed?

      @command = <<-EOS
        openstack #{sub_command} --os-auth-url #{auth_url}
        --os-token #{OpenStackCommand.get_project_tokens(user)[project_name]}
        --os-project-name #{project_name} --os-username #{user.email}
        --os-default-domain default --os-identity-api-version 3
      EOS
      @command << token_endpoint_params

      @command.strip!
      @command.gsub! /\s+/, " "
    end

    def to_s
      @command
    end

    def is_allowed?
      return true if sub_command.downcase.strip == 'help'
      OpenStackCommand.sub_commands.values.flatten.any?{|s| sub_command.gsub(/^help/,'').strip.downcase.starts_with?(s)}
    end

    def command_is?(type)
      OpenStackCommand.sub_commands[type].any? {|s| sub_command.starts_with?(s)}
    end

    def self.categories
      [
        {
          name:   "compute",
          module: "openstack.compute.v2"
        },
        {
          name:   "volume",
          module: "openstack.volume.v2"
        },
        {
          name:   "identity",
          module: "openstack.identity_endpoint_base.v2"
        },
        {
          name:   "image",
          module: "openstack.image.v2"
        },
        {
          name:   "network",
          module: "openstack.network.v2"
        },
        {
          name:   "storage",
          module: "openstack.object_store.v1"
        }
      ]
    end

    categories.each do |category|
      define_singleton_method "#{category[:name]}_endpoint_base" do
        var_name = "@@#{category[:name]}_endpoint_base".to_sym
        res = class_variable_get(var_name) rescue nil
        return res if res
        class_variable_set var_name,
                           OpenStackConnection.send(category[:name]).instance_variable_get("@openstack_management_uri").to_s.gsub(/\/\w+$/,'')                  
      end
    end
    categories.each do |category|
      define_method "#{category[:name]}?" do
        send("#{category[:name]}_endpoint".to_sym) if command_is? category[:module]
      end
    end

    def token_endpoint_params
      endpoint = compute? || image? || network?
      endpoint ? " --os-url #{endpoint} --os-auth-type token_endpoint" : " --os-auth-type token"
    end

    def self.help
      File.read(File.expand_path(File.join(File.dirname(__FILE__), "./text/help.txt")))
    end

    def self.commands
      File.read(File.expand_path(File.join(File.dirname(__FILE__), "./text/commands.txt")))
    end

    def self.sub_commands
      { 
        "openstack.cli"             => ["help", "commands", "clear", "nyan", "save", "stranger"],
        "openstack.common"          => ["availability zone list", "configuration show", "limits show", "quota show"],
        "openstack.compute.v2"      => ["console", "console log", "console log show", "console url show",
                                        "flavor list", "flavor show",
                                        "ip fixed add", "ip fixed remove", "ip floating add",
                                        "ip floating pool", "ip floating pool list", "ip floating remove", "keypair create", "keypair delete",
                                        "keypair list", "keypair show", "server add security group", "server add volume",
                                        "server backup create", "server create", "server delete", "server dump create",
                                        "server group create", "server group delete", "server group list", "server group show",
                                        "server image create", "server list", "server lock", "server migrate", "server pause",
                                        "server reboot", "server rebuild", "server remove security group", "server remove volume",
                                        "server rescue", "server resize", "server restore", "server resume", "server set",
                                        "server show", "server start", "server stop", "server suspend",
                                        "server unlock", "server unpause", "server unrescue", "server unset",
                                        "usage list", "usage show"],
        "openstack.identity.v2"     => ["catalog list", "catalog show",
                                        "ec2 credentials list", "ec2 credentials show"],
        "openstack.image.v2"        => ["image add project", "image delete", "image list",
                                        "image remove project", "image set", "image show", "image unset"],
        "openstack.network.v2"      => ["ip floating create", "ip floating delete", "ip floating list",
                                        "ip floating show", "network create", "network delete", "network list",
                                        "network set", "network show", "port create", "port delete", "port list", "port set", "port show", "router add port",
                                        "router add subnet", "router create", "router delete", "router list", "router remove port", "router remove subnet",
                                        "router set", "router show", "security group create", "security group delete", "security group list",
                                        "security group rule create", "security group rule delete", "security group rule list", "security group rule show",
                                        "security group set", "security group show", "subnet create", "subnet delete", "subnet list", "subnet pool create",
                                        "subnet pool delete", "subnet pool list", "subnet pool set", "subnet pool show", "subnet set", "subnet show"],
        "openstack.object_store.v1" => ["container create", "container delete", "container list", "container set", "container show",
                                        "container unset", "object delete", "object list", "object set", "object show",
                                        "object store account set", "object store account show", "object store account unset", "object unset"],
        "openstack.volume.v2"       => ["backup create", "backup delete", "backup list", "backup restore", "backup show", "snapshot create", "snapshot delete",
                                        "snapshot list", "snapshot set", "snapshot show", "snapshot unset", "volume create", "volume delete", "volume list",
                                        "volume set", "volume show", "volume transfer request list", "volume type list", "volume type show", "volume unset"]
      }
    end

    def self.get_project_tokens(user, password=nil)
      Rails.cache.fetch("os_tokens_user_#{user.id}", expires_in: 4.hours, force: !!password) do
        Hash[user.primary_organization.projects.map {|project|
          begin
            args = OpenStackConnection.configuration.dup
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

    def self.revoke_project_tokens(user)
      return unless Rails.env.production?
      key = "os_tokens_user_#{user.id}"
      Rails.cache.fetch(key)&.values&.each do |token|
        begin
          OpenStackConnection.identity.token_revoke(token)
        rescue Fog::Identity::OpenStack::NotFound
          # do nothing
        rescue Fog::Errors::Error => e
          Honeybadger.notify(e)
        end
      end
      Rails.cache.delete(key)
    end

    def compute_endpoint
      "#{OpenStackCommand.compute_endpoint_base}/#{project_uuid}"
    end

    def volume_endpoint
      "#{OpenStackCommand.volume_endpoint_base}/#{project_uuid}"
    end

    def identity_endpoint
      OpenStackCommand.identity_endpoint_base
    end

    def image_endpoint
      OpenStackCommand.image_endpoint_base
    end

    def network_endpoint
      OpenStackCommand.network_endpoint_base
    end

    def storage_endpoint
      OpenStackCommand.storage_endpoint_base
    end
  end
end
