class TrainingAccountGenerator
  attr_reader :count, :email_domain, :quota, :accounts, :project_name

  def initialize(count: nil, email_domain: nil, project_name: nil)
    @count        = count
    @email_domain = email_domain
    @project_name = project_name
    @accounts     = []
  end

  def generate!
    @accounts = (1..count).map do |index|
      username = "test_account_#{index}@#{email_domain}"
      password = random_password

      cg = CustomerGenerator.new(
        organization_name: "#{email_domain}_#{index}",
        extra_projects:    '',
        organization: { product_ids: ["1","2"] },
        salesforce_id: 'NA',
        email: username
      )
      cg.generate!
      cg.organization.update_attributes(quota_limit: StartingQuota['training'], test_account: true)
      cg.organization.primary_project.update_attributes! name: "#{project_name}_#{index}", quota_set: StartingQuota['training']
      rg = RegistrationGenerator.new(cg.invite, password: password)
      rg.generate!
      {
        username: username,
        password: password,
        project:  cg.organization.primary_project.name
      }
    end
  end

  private

  def random_password
    rand(36**10).to_s(36)
  end
end