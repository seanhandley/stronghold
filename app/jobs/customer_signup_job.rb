class CustomerSignupJob < ActiveJob::Base
  queue_as :default

  def perform(id)
    CustomerSignupGenerator.new(id).generate!
  end
end