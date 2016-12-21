require_relative '../../lib/soulmate_loader'

$soulmate_job_mutex = Mutex.new

class SoulmateJob < ActiveJob::Base
  queue_as :default

  def perform
    return if $soulmate_job_mutex.locked?
    $soulmate_job_mutex.synchronize do
      SoulmateLoader.load_search_terms
    end
  end
end
