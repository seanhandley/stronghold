class OrganizationTicket

  def initialize(options = {})
    @reference = options[:reference]
    @title = options[:title]
    @description = options[:description]
  end

  attr_accessor :reference
  attr_accessor :title
  attr_accessor :description
  attr_accessor :jira_status

end