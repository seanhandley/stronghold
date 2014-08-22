class Ticket
  include TicketsHelper

  def initialize(jira_issue = {})
    @reference = jira_issue['key']
    @title = jira_issue['fields']['summary']
    @description = markdown jira_issue['fields']['description']
    @jira_status = jira_issue['fields']['status']['name']
    @time_created = jira_issue['fields']['created']
    @time_updated = jira_issue['fields']['updated']
    @comments = jira_issue['fields']['comment']['comments'].collect do |jira_comment|
      # jira_comment
      TicketComment.new(jira_comment)
    end
  end

  attr_accessor :reference, :title, :description, :jira_status, :comments

end