require 'faraday'

class Tickets
  include TicketsHelper
  include ActionView::Helpers::TextHelper

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
    response_body = JSON.parse response.body
    response_body['issues'].collect do |jira_issue|
      Ticket.new(jira_issue)
      # jira_issue
    end
  end

  def create(title, description, email)

    title = "[title]" if title.nil?
    description = "[description]" if description.nil?
    description = "[[USERNAME:#{email}]]\n\n" + description

    url = @settings['base_url'] + 'issue'
    json = {
      "fields" => {
        "project" => {
          "key" => @settings['project']
        },
        "issuetype" => {
          "name" => "Bug"
        },
        "summary" => title,
        "reporter" => {
          "name" => "issues",
        },
        "assignee" => {
          "name" => "issues",
        },
        "labels" => [@reference],
        "description" => description
      }
    }.to_json

    response = @connection.post url, json
    response_body = JSON.parse response.body
    audit(response_body['key'], 'create', {title: title, description: truncate_for_audit(description)})
    response_body['key']

  end

  def create_comment(issue_reference, text, email)
    url = @settings['base_url'] + 'issue/' + issue_reference + '/comment'
    text = "[[USERNAME:#{email}]]\n\n" + text
    comment = {
      "body" => text
    }
    response = @connection.post url, comment.to_json
    response_body = JSON.parse response.body
    audit(issue_reference, 'comment', {content: truncate_for_audit(text.sub(/\[\[USERNAME:(.+)\]\]\n\n/,''))})
    response_body
  end

  def destroy_comment(issue_reference, comment_id)
    url = @settings['base_url'] + 'issue/' + issue_reference + '/comment/' + comment_id
    response = @connection.delete url
    (response.body.length == 0)
  end

  def change_status(issue_reference, status)
    url = @settings['base_url'] + 'issue/' + issue_reference + '/transitions?expand=transitions.fields'
    transitions_response = @connection.get url
    transitions = JSON.parse transitions_response.body
    transitions = transitions['transitions']
    status_transition = transitions.select {|transition|
      transition['to']['name'] == status
    }.first
    return nil if status_transition == nil
    transition_id = status_transition['id']
    change = {
      "transition" => {
        "id" => transition_id
      }
    }
    change_response = @connection.post url, change.to_json
    audit(issue_reference, 'update_status', {reference: issue_reference, status: display_status(status)})
    return ""
    # change_response_body = JSON.parse change_response.body
    # status_transition
  end

  private

  def audit(id, action, params)
    Audited::Adapters::ActiveRecord::Audit.create auditable_id: id, auditable_type: 'Ticket', action: action,
                 user: Authorization.current_user,
                 organization_id: Authorization.current_user.organization_id,
                 audited_changes: params.stringify_keys!
  end

  def display_status(status)
    case status
    when 'To Do'
      'Open'
    when 'Done'
      'Closed'
    end
  end

  def truncate_for_audit(content)
    truncate(content, omission: '...', separator: '', length: 300)
  end
end