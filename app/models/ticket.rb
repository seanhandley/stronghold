class Ticket

  def initialize(jira_issue = {})
    @reference = jira_issue['key']
    @title = jira_issue['fields']['summary']
    @description = jira_issue['fields']['description']
    @jira_status = jira_issue['fields']['status']['name']
    @comments = jira_issue['fields']['comment']['comments'].collect do |jira_comment|
      TicketComment.new(jira_comment)
    end
  end

  attr_accessor :reference
  attr_accessor :title
  attr_accessor :description
  attr_accessor :jira_status
  attr_accessor :comments

end