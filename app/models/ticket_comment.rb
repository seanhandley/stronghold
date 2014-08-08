class TicketComment

  def initialize(jira_comment = {})
    @email = jira_comment['author']['emailAddress']
    @content = jira_comment['body']
  end

  attr_accessor :email
  attr_accessor :content

end