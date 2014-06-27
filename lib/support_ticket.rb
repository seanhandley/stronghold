require 'jira'

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

    def all(reference)
      return project.issues.select do |issue|
        (issue.fields['labels'].first == reference)
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