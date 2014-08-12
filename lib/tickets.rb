require 'faraday'
require 'faraday_middleware'

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
    Rails.cache.fetch("organization_#{@reference}_tickets", expires_in: 20.seconds) do
      url = @settings['base_url'] + 'search/?jql=project=' + @settings['project'] + ' AND labels in ("' + @reference + '")&fields=*all'
      response = @connection.get url
      responseBody = JSON.parse response.body
      responseBody['issues'].collect do |jira_issue|
        Ticket.new(jira_issue)
        # jira_issue
      end
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

  def add_comment(reference, text)
    url = @settings['base_url'] + 'issue/' + reference + '/comment'
    json = '{
      "body": "' + text + '",
      "author": {
        "name": "issues"
      }
    }'
    response = @connection.post url, json
    responseBody = JSON.parse response.body
    responseBody
    # url
    # "Comment Added for " + reference + "!"
  end

end