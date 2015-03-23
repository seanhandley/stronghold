class UsageSanityJob < ActiveJob::Base
  queue_as :default

  def perform
    Billing.sync!
    check = Sanity.check
    Sanity.notify!(check) unless check[:sane]
  end
end