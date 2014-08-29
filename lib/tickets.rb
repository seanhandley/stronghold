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
      # jira_issue
      reference = jira_issue['key']
      title = jira_issue['fields']['summary']
      email, description = extract_issue_email(jira_issue)
      status = jatus_to_status(jira_issue['fields']['status']['name'])
      new_ticket = Ticket.new(
        reference,
        title,
        email,
        description,
        status
      )
      new_ticket.comments = jira_issue['fields']['comment']['comments'].collect do |jira_comment|
        # jira_comment
        TicketComment.new(jira_comment)
      end
      new_ticket
    end
  end

  def create(title, description, email)

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
        "description" => "[[USERNAME:#{email}]]\n\n" + description
      }
    }.to_json

    response = @connection.post url, json
    response_body = JSON.parse response.body
    reference = response_body['key']
    title = truncate_for_audit(title)
    truncate_for_audit(description)
    audit(reference, 'create', {title: title, description: description})
    Hipchat.notify('Support', "New ticket <a href=\"https://datacentred.atlassian.net/browse/#{reference}\">#{reference}</a> created by #{email}: #{title}")
    reference

  end

  def create_comment(reference, text, email)
    url = @settings['base_url'] + 'issue/' + reference + '/comment'
    comment = {
      "body" => "[[USERNAME:#{email}]]\n\n" + text
    }
    response = @connection.post url, comment.to_json
    response_body = JSON.parse response.body
    text = truncate_for_audit(text)
    audit(reference, 'comment', {content: text})
    Hipchat.notify('Support', "#{email} replied to ticket <a href=\"https://datacentred.atlassian.net/browse/#{reference}\">#{reference}</a>: #{text}")
    response_body
  end

  # def destroy_comment(issue_reference, comment_id)
  #   url = @settings['base_url'] + 'issue/' + issue_reference + '/comment/' + comment_id
  #   response = @connection.delete url
  #   (response.body.length == 0)
  # end

  def change_status(reference, status)
    url = @settings['base_url'] + 'issue/' + reference + '/transitions?expand=transitions.fields'
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
    audit(reference, 'update_status', {reference: reference, status: status})

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

  def jatus_to_status(status)
    case status
      when 'To Do', 'In Progress'
        'Open'
      when 'Done'
        'Closed'
    end
  end

  def status_to_jatus(jatus)
    case jatus
      when 'Open'
        'To Do'
      when 'Closed'
        'Done'
    end
  end

  def truncate_for_audit(content)
    truncate(content, omission: '...', separator: '', length: 300)
  end
end