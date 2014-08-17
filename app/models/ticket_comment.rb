class TicketComment
  include TicketsHelper

  def initialize(jira_comment = {})
    @id = jira_comment['id']
    @email = jira_comment['author']['emailAddress']
    @content = markdown jira_comment['body']
    @time = jira_comment['updated']
  end

  attr_accessor :id
  attr_accessor :email
  attr_accessor :content

end