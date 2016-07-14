class ReaperJob < ActiveJob::Base
  queue_as :default

  def perform
    Reaper.reap
  end
end
