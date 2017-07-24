class UsageSanityJob < ApplicationJob
  queue_as :slow

  def perform
    check = Sanity.check
    if check[:sane]
      Notifications.notify(:good, 'Sanity check passed.')
    else
      Sanity.notify!(check)
      JanitorJob.perform_later(check)
    end
  end
end