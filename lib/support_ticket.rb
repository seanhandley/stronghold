require 'jira'

module IssueStatus
  ToDo       = 'To Do'
  InProgress = 'In Progress'
  Done       = 'Done'
end

class SupportTicket

  attr_accessor :id, :title, :description

  def initialize(obj)
    @obj = obj
  end

  def id
    @obj.key
  end

  def title
    @obj.summary
  end

  def description
    @obj.description
  end

  def self.create(params)
    issue = self.project.client.Issue.build
    expected_params = {'summary' => params[:title], "issuetype"=>{"id"=>"1"}}
    issue.save({
      "fields" => {
        "project" => {
          "id" => self.project.attrs['id']
        },
        "labels" => [params[:reference]]
      }.merge(expected_params)
    })
    new issue
  end

  class << self

    def filter(reference, statuses)
    end

    def all(reference)
    end

    def open(reference)
      project.issues.select do |issue|
        [
          (issue.fields['labels'].first == reference),
          ([IssueStatus::ToDo, IssueStatus::InProgress].include?(issue.fields['status']['name'])),
        ].all?
      end
    end

    def closed(reference)
      project.issues.select do |issue|
        [
          (issue.fields['labels'].first == reference),
          (issue.fields['status']['name'] == IssueStatus::Done),
        ].all?
      end
    end

    def client
      JIRA::Client.new(JIRA_ARGS)
    end

    def project
      client.Project.find("ST")
    end
  end

end