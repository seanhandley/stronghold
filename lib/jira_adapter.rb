require 'faraday'
require 'faraday_middleware'

class JiraAdapter

  def initialize

    # Settings
    @settings = YAML.load_file("#{Rails.root}/config/jira.yml")[Rails.env]
    @settings['password'] = Rails.application.secrets['jira_password']

  end

  def issues(reference)

    ENV['JIRA_USER']= 'stronghold'
    ENV['JIRA_PASS'] = 'X'
    ENV['JIRA_URL'] = 'https://datacentred.atlassian.net'

    api_auth_path = '/rest/auth/latest/session'
    api_base_path = '/rest/api/latest/'
     
    jira = Faraday.new ENV['JIRA_URL'] do |req|
      req.request :json
      req.response :json, :content_type => /\bjson$/
      req.adapter  Faraday.default_adapter
    end

    #Auth
    resp = jira.post api_auth_path, username: ENV['JIRA_USER'], password: ENV['JIRA_PASS']
    cookie = resp.body["session"]
    cookie &&= cookie["name"] + ?= + cookie["value"]
    jira.headers.merge! cookie: cookie

    res = jira.get(api_base_path+'issue/ST-9.json')

    return [res]

  end

end