settings = YAML.load_file("#{Rails.root}/config/jira.yml")[Rails.env]

JIRA_ARGS = {
	:username => settings['username'],
	:password => Rails.application.secrets['jira_password'],
	:site => settings['url'],
	:auth_type => :basic,
	:context_path => ''
}