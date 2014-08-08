class Ticket

  def initialize(jira_issue = {})
    @reference = jira_issue['key']
    @title = jira_issue['fields']['summary']
    @description = jira_issue['fields']['description']
    @jira_status = jira_issue['fields']['status']['name']
  end

  attr_accessor :reference
  attr_accessor :title
  attr_accessor :description
  attr_accessor :jira_status

end