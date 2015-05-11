class StatusIOSubscribeJob < ActiveJob::Base
  queue_as :default

  def perform(email)
    StatusIO.add_subscriber email
  end
end