require 'faraday'
require 'faraday_middleware'

class JiraAdapter

  def initialize

    @settings = YAML.load_file("#{Rails.root}/config/jira.yml")[Rails.env]
    @settings['password'] = Rails.application.secrets['jira_password']

  end

  def issues(reference)

    @connection = Faraday.new
    @connection.basic_auth(@settings['username'], @settings['password'])
    url = @settings['base_url'] + 'search/?jql=project=ST&fields=*all'
    response = @connection.get url
    responseBody = JSON.parse response.body
    return [responseBody]

  end

end