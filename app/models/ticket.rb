class Ticket
  include TicketsHelper

  attr_accessor :reference, :title, :description, :jira_status, :comments

  def initialize(jira_issue = {})
    @reference = jira_issue['key']
    @title = jira_issue['fields']['summary']
    @email, @description = extract_issue_email(jira_issue)
    @jira_status = jira_issue['fields']['status']['name']
    @time_created = jira_issue['fields']['created']
    @time_updated = jira_issue['fields']['updated']
    @comments = jira_issue['fields']['comment']['comments'].collect do |jira_comment|
      # jira_comment
      TicketComment.new(jira_comment)
    end
  end

  def self.find(params)
    nil
  end

end