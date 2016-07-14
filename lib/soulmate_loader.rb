class SoulmateLoader
  include Rails.application.routes.url_helpers
  def load_search_terms
    loader = Soulmate::Loader.new("organization")

    Organization.all.each do |customer|
      loader.remove("id" => customer.id)
    end

    Organization.all.each do |customer|
      loader.add("term" => customer.name, "aliases" => [customer.reporting_code], "id" => customer.id,
                 "data" => {"url" => admin_customer_path(customer),   "additional_info" => customer.reporting_code})
    end

    loader = Soulmate::Loader.new("user")

    User.all.each do |user|
      loader.remove("id" => user.id)
    end

    User.all.each do |user|
      if user.organization
        loader.add("term" => user.email, "aliases" => [user.name, user.uuid], "id" => user.id,
                   "data" => {"url" => admin_customer_path(user.organization), "additional_info" => user.uuid})
      end
    end

    loader = Soulmate::Loader.new("project")

    Project.all.each do |project|
      loader.remove("id" => project.id)
    end

    Project.all.each do |project|
      if project.organization
        loader.add("term" => project.name, "aliases" => [project.name, project.uuid], "id" => project.id,
                   "data" => {"url" => admin_customer_path(project.organization), "additional_info" => project.uuid})
      end
    end
  end

  def self.load_search_terms
    new.load_search_terms
  end
end