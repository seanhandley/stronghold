class StatusIOSubscribeJob < ActiveJob::Base
  queue_as :default

  def perform(action, email)
    StatusIO.send(action.to_sym, email)
  end
end