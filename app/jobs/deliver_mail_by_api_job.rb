class DeliverMailByApiJob < ApplicationJob
  queue_as :mailers

  def perform(mail_attributes)
    Deliverhq::send mail_attributes
  end
end
