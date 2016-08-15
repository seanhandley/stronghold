class ReaperJob < ActiveJob::Base
  queue_as :default

  def perform
    Reaper.new.reap(false)
  end
end
