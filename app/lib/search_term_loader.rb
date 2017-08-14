class SearchTermLoader
  include Rails.application.routes.url_helpers
  def load_search_terms
    loader = Soulheart::Loader.new

    data = []

    Organization.all.each do |customer|
      data << {'text' => customer.name, 'category' => 'Organization',
        'id' => customer.id, 'data' => {
          'url' => admin_customer_path(customer),
          'display_name'    => "#{customer.name} (#{customer.reporting_code})"
        }
      }
      data << {'text' => customer.reporting_code, 'category' => 'Organization',
        'id' => customer.reporting_code, 'data' => {
          'url' => admin_customer_path(customer),
          'display_name'    => "#{customer.name} (#{customer.reporting_code})"
        }
      }
    end

    User.all.each do |user|
      user.organization_users.each do |organization_user|
        user         = organization_user.user
        organization = organization_user.organization
        next unless organization && user
        data << {'text' => user.email, 'category' => 'User',
          'id' => "organization_user_#{user.email}", 'data' => {
            'url' => admin_customer_path(organization),
            'display_name' => "#{user.email} (#{user.uuid} / #{user.name})"
          }
        }
        data << {'text' => user.name, 'category' => 'User',
          'id' => "organization_user_#{organization_user.id}", 'data' => {
            'url' => admin_customer_path(organization),
            'display_name' => "#{user.email} (#{user.uuid} / #{user.name})"
          }
        }
        data << {'text' => user.uuid, 'category' => 'User',
          'id' => "organization_user_#{user.uuid}", 'data' => {
            'url' => admin_customer_path(organization),
            'display_name' => "#{user.email} (#{user.uuid} / #{user.name})"          }
        }
      end
    end

    Project.all.each do |project|
      if project.organization
        data << {'text' => project.name, 'category' => 'Project', 'aliases' => [project.name, project.uuid],
          'id' => "project_#{project.id}", 'data' => {
            'url' => admin_customer_path(project.organization),
            'display_name' => "#{project.name} (#{project.uuid})"
          }
        }
        data << {'text' => project.uuid, 'category' => 'Project',
          'id' => "project_#{project.uuid}", 'data' => {
            'url' => admin_customer_path(project.organization),
            'display_name' => "#{project.name} (#{project.uuid})"
          }
        }
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
