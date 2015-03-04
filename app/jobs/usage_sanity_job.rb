class UsageSanityJob < ActiveJob::Base
  queue_as :default

  def perform
    check = Sanity.check
    Sanity.notify!(check) unless check[:sane]
  end
end