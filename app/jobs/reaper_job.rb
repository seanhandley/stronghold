class ReaperJob < ActiveJob::Base
  queue_as :default

  def perform
    Reaper.new.reap
  end
end
