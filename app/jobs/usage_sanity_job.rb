class UsageSanityJob < ActiveJob::Base
  queue_as :default

  def perform
    Sanity.notify!(Sanity.check)
  end
end