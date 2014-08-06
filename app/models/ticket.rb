class Ticket

  def initialize(jira_attrs = {})
    @reference = jira_attrs['key']
    @title = jira_attrs['fields']['summary']
    @description = jira_attrs['fields']['description']
    @jira_status = jira_attrs['fields']['status']['name']
  end

  attr_accessor :reference
  attr_accessor :title
  attr_accessor :description
  attr_accessor :jira_status

end