module TerminalHelper
  def options_for_terminal_projects(projects)
    options_for_select projects.collect{|p| ["Project: #{p.reference}", p.reference]}    
  end
end