class TicketComment
  include TicketsHelper

  def initialize(jira_comment = {})
    @id = jira_comment['id']
    @email, @content = extract_username_from_comment(jira_comment)
    @time = jira_comment['updated']
  end

  attr_accessor :id
  attr_accessor :email
  attr_accessor :content

  private

  def extract_username_from_comment(jira_comment)
    jira_comment['body'].gsub!("\r",'')
    m = jira_comment['body'].match(/\[\[USERNAME:(.+)\]\]\n\n/)
    if m == nil
      return [jira_comment['author']['emailAddress'], markdown(jira_comment['body'])]
    else
      return [m[1], markdown(jira_comment['body'].sub(m[0],''))]
    end
  end

end