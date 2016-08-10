class SearchTermLoader
  include Rails.application.routes.url_helpers
  def load_search_terms
    loader = Soulheart::Loader.new

    data = []

    Organization.all.each do |customer|
      data << {'text' => customer.name, 'category' => 'Organization', 'aliases' => [customer.reporting_code],
        'id' => customer.id, 'data' => {'url' => admin_customer_path(customer), 'additional_info' => customer.reporting_code} }
    end

    User.all.each do |user|
      user.organizations.each do |organization|
        data << {'text' => user.email, 'category' => 'User', 'aliases' => [user.name, user.uuid],
          'id' => user.id, 'data' => {'url' => admin_customer_path(organization), 'additional_info' => "#{user.uuid} / #{organization.reporting_code}" }}
      end
    end

    Project.all.each do |project|
      if project.organization
         data << {'text' => project.name, 'category' => 'Project', 'aliases' => [project.name, project.uuid],
          'id' => project.id, 'data' => {'url' => admin_customer_path(project.organization), 'additional_info' => project.uuid} }
      end
    end

    loader.load data
  end

  def self.load_search_terms
    new.load_search_terms
  end
end

if Rails.env.development?
  begin
    Rails.application.reload_routes!
    SearchTermLoader.load_search_terms
  rescue StandardError => e
    puts "Couldn't load search terms: #{e.to_s}"
  end
end
