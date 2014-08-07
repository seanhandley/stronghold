class Organization < ActiveRecord::Base
  audited
  has_associated_audits

  after_save :generate_reference, :on => :create
  after_initialize :init_jira_adapter

  validates :name, length: {minimum: 1}, allow_blank: false
  validates :reference, :uniqueness => true

  has_many :users
  has_many :roles
  has_many :invites

  def init_jira_adapter
    @jira_adapter = JiraAdapter.new
  end

  def tickets
    Rails.cache.fetch("organization_#{@reference}_issues", expires_in: 1.seconds) do
      @jira_adapter.issues(reference).collect do |issue|
        issue
        # Ticket.new(issue.attrs)
      end
    end
  end

  private

  def generate_reference
    return nil if reference
    generate_reference_step(name.parameterize.gsub('-','').upcase.slice(0,8), 0)
  end

  def generate_reference_step(ref, count)
    new_ref = "#{ref}#{count == 0 ? '' : count }"
    if Organization.all.collect(&:reference).include?(new_ref)
      generate_reference_step(ref, (count+1))
    else
      update_column(:reference, new_ref)
    end
  end

end