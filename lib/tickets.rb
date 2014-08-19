require 'faraday'

class Tickets

  def initialize(reference)
    @reference = reference
    @settings = YAML.load_file("#{Rails.root}/config/jira.yml")[Rails.env]
    @settings['password'] = Rails.application.secrets['jira_password']
    @connection = Faraday.new
    @connection.headers = {'Content-Type' => 'application/json'}
    @connection.basic_auth(@settings['username'], @settings['password'])
  end

  def all
    url = @settings['base_url'] + 'search/?jql=project=' + @settings['project'] + ' AND labels in ("' + @reference + '")&fields=*all'
    response = @connection.get url
    responseBody = JSON.parse response.body
    responseBody['issues'].collect do |jira_issue|
      Ticket.new(jira_issue)
      # jira_issue
    end
  end

  def create(title, description, email)

    title = "[title]" if title.nil?
    description = "[description]" if description.nil?

    url = @settings['base_url'] + 'issue'
    json = '{
      "fields": {
        "project": {
          "key": "' + @settings['project'] + '"
        },
        "summary": "' + title + '",
        "issuetype": {
          "name": "Bug"
        },
        "reporter": {
          "name": "issues",
          "email": "' + email + '"
        },
        "assignee": {
          "name": "issues",
          "email": ""
        },
        "labels": [
          "' + @reference + '"
        ],
        "description": "' + description + '"
      }
    }'

    response = @connection.post url, json
    responseBody = JSON.parse response.body
    responseBody
    responseBody['key']

  end

  def create_comment(issue_reference, text, username)
    url = @settings['base_url'] + 'issue/' + issue_reference + '/comment'
    text = "[[USERNAME:#{username}]]\n\n" + text
    comment = {
      "body" => text
    }
    response = @connection.post url, comment.to_json
    responseBody = JSON.parse response.body
    responseBody
  end

  def destroy_comment(issue_reference, comment_id)
    url = @settings['base_url'] + 'issue/' + issue_reference + '/comment/' + comment_id
    response = @connection.delete url
    (response.body.length == 0)
  end

end