class TicketComment
  include TicketsHelper

  def initialize(jira_comment = {})
    @id = jira_comment['id']
    @email, @content = extract_comment_email(jira_comment)
    @time = jira_comment['updated']
  end

  attr_accessor :id
  attr_accessor :email
  attr_accessor :content

end