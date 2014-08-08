class TicketComment

  def initialize(jira_comment = {})
    @email = jira_comment['author']['emailAddress']
    @content = jira_comment['body']
    @time = jira_comment['updated']
  end

  attr_accessor :email
  attr_accessor :content

end