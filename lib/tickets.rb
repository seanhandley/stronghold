require 'faraday'
require 'faraday_middleware'

class Tickets

  def initialize(reference)
    @reference = reference
    @settings = YAML.load_file("#{Rails.root}/config/jira.yml")[Rails.env]
    @settings['password'] = Rails.application.secrets['jira_password']
    @connection = Faraday.new
    @connection.basic_auth(@settings['username'], @settings['password'])
  end

  def all
    Rails.cache.fetch("organization_#{@reference}_tickets", expires_in: 20.seconds) do
      url = @settings['base_url'] + 'search/?jql=project=' + @settings['project'] + '&fields=*all'
      response = @connection.get url
      responseBody = JSON.parse response.body
      responseBody['issues'].collect do |jira_issue|
        # jira_issue
        Ticket.new(jira_issue)
      end
    end

  end

  def create(title, description)
    "ST-15"
  end

end