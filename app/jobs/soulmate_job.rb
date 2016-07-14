require_relative '../../lib/soulmate_loader'

class SoulmateJob < ActiveJob::Base
  queue_as :default

  def perform
    SoulmateLoader.load_search_terms
  end
end
