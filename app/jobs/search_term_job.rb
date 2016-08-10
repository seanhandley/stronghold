$search_term_job_mutex = Mutex.new

class SearchTermJob < ActiveJob::Base
  queue_as :default

  def perform
    return if $search_term_job_mutex.locked?
    $search_term_job_mutex.synchronize do
      SearchTermLoader.load_search_terms
    end
  end
end
