module TerminalHelper
  def options_for_terminal_projects
    options_for_select current_user.projects.uniq.collect{|p| ["Project: #{p.reference}", p.reference]}    
  end

  def example_commands
    [
      {
        command: "flavor list",
        description: "List all the available instance flavors"
      },
      {
        command: "image list",
        description: "List all the available images"
      },
      {
        command: "server create --flavor <strong>[flavor]</strong> --image <strong>[image] [name]</strong>".html_safe,
        description: "Create a new instance"
      },
      {
        command: "server list",
        description: "List all the available servers"
      },
      {
        command: "ip floating create external".html_safe,
        description: "Create a new floating IP in this project with a public address on the external network."
      },
      {
        command: "ip floating add <strong>[address] [server_id]</strong>".html_safe,
        description: "Add an existing floating IP to an existing server"
      }
    ]
  end
end