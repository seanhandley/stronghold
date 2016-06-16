class SoulmateJob < ActiveJob::Base
  queue_as :default
  include Rails.application.routes.url_helpers

  def perform
    loader = Soulmate::Loader.new("organization")

    Organization.all.each do |customer|
      loader.remove("id" => customer.id)
    end

    Organization.all.each do |customer|
      loader.add("term" => customer.name, "aliases" => [customer.reporting_code], "id" => customer.id,
                 "data" => {"url" => admin_customer_path(customer),   "reporting_code" => customer.reporting_code})
    end

  end
end
