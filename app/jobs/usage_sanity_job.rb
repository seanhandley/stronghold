class UsageSanityJob < ApplicationJob
  queue_as :default

  def perform
    check = Sanity.check
    if check[:sane]
      Notifications.notify(:good, 'Sanity check passed.')
    else
      Sanity.notify!(check)
    end
  end
end