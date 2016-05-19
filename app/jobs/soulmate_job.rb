class SoulmateJob < ActiveJob::Base
  queue_as :default
  include Rails.application.routes.url_helpers

  def perform
    loader = Soulmate::Loader.new("organization")

    Organization.all.each do |customer|
      loader.add("term" => customer.name, "id" => customer.id, "data" => {"url" => admin_customer_path(customer)})
    end

  end
end
